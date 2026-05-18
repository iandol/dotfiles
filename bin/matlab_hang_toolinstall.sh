#!/usr/bin/env zsh
# install_matlab_debug_tools.zsh
#
# Install/check low-level debugging and profiling tools for the MATLAB hang
# capture script on Ubuntu/Debian systems.
#
# Usage:
#   chmod +x install_matlab_debug_tools.zsh
#   ./install_matlab_debug_tools.zsh
#
# Optional environment variables:
#   NO_APT_UPDATE=1          Skip apt-get update
#   NO_FLAMEGRAPH_GIT=1     Do not clone Brendan Gregg's FlameGraph repo if apt package is unavailable
#   RELAX_PERF_SYSCTL=1     Write /etc/sysctl.d/99-matlab-profiling.conf to make perf symbols easier to see
#   DRY_RUN=1               Print commands but do not install/change anything
#
# Notes:
#   - The MATLAB collector itself still uses sudo for strace/perf/bpftrace.
#   - RELAX_PERF_SYSCTL lowers kernel profiling restrictions. Use only on a trusted machine.

emulate -L zsh
set -u
set -o pipefail

SCRIPT_NAME=${0:t}
KERNEL_RELEASE=$(uname -r)
FLAMEGRAPH_DIR=/opt/FlameGraph

DRY_RUN=${DRY_RUN:-0}
NO_APT_UPDATE=${NO_APT_UPDATE:-0}
NO_FLAMEGRAPH_GIT=${NO_FLAMEGRAPH_GIT:-0}
RELAX_PERF_SYSCTL=${RELAX_PERF_SYSCTL:-0}

log()  { print -r -- "[$(date '+%F %T')] $*"; }
warn() { print -r -- "[$(date '+%F %T')] WARNING: $*" >&2; }
die()  { print -r -- "[$(date '+%F %T')] ERROR: $*" >&2; exit 1; }

run() {
  print -r -- "+ $*"
  if [[ "$DRY_RUN" == "1" ]]; then
    return 0
  fi
  "$@"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

apt_available() {
  local pkg="$1"
  apt-cache policy "$pkg" 2>/dev/null | awk '/Candidate:/ {print $2}' | grep -qvE '^(\(none\)|)$'
}

add_pkg_if_available() {
  local pkg="$1"
  if apt_available "$pkg"; then
    APT_PACKAGES+=("$pkg")
  else
    SKIPPED_PACKAGES+=("$pkg")
  fi
}

require_apt_system() {
  [[ "$(uname -s)" == "Linux" ]] || die "This installer is intended for Linux."
  have_cmd apt-get || die "apt-get not found. This script currently supports Ubuntu/Debian-style systems."
  have_cmd apt-cache || die "apt-cache not found. Cannot inspect package availability."
}

require_sudo() {
  if [[ "$EUID" -eq 0 ]]; then
    SUDO=()
    return 0
  fi
  have_cmd sudo || die "sudo is required when not running as root."
  log "Checking sudo access..."
  run sudo -v || die "Could not obtain sudo privileges."
  SUDO=(sudo)
}

install_apt_packages() {
  typeset -ga APT_PACKAGES SKIPPED_PACKAGES
  APT_PACKAGES=()
  SKIPPED_PACKAGES=()

  # Core commands used directly by matlab_hang_capture.zsh or useful in follow-up analysis.
  local base_candidates=(
    ca-certificates
    curl
    wget
    git
    coreutils
    procps
    psmisc
    util-linux
    iproute2
    strace
    linux-tools-common
    linux-tools-generic
    "linux-tools-${KERNEL_RELEASE}"
    "linux-headers-${KERNEL_RELEASE}"
    bpftrace
    bpfcc-tools
    sysstat
    lsof
    gdb
    elfutils
    binutils
    trace-cmd
    iotop
    numactl
    jq
    zsh
    flamegraph
  )

  for pkg in "${base_candidates[@]}"; do
    add_pkg_if_available "$pkg"
  done

  # Deduplicate while preserving order.
  local -a unique_pkgs
  unique_pkgs=(${(u)APT_PACKAGES})

  if [[ "$NO_APT_UPDATE" != "1" ]]; then
    log "Updating apt package lists..."
    run "${SUDO[@]}" apt-get update
  else
    warn "Skipping apt-get update because NO_APT_UPDATE=1."
  fi

  if (( ${#unique_pkgs[@]} > 0 )); then
    log "Installing available packages..."
    run "${SUDO[@]}" apt-get install -y "${unique_pkgs[@]}"
  else
    warn "No apt packages selected; this is unexpected."
  fi

  if (( ${#SKIPPED_PACKAGES[@]} > 0 )); then
    warn "These package names were not available in your configured apt repositories: ${(j:, :)SKIPPED_PACKAGES}"
  fi
}

install_flamegraph_from_git_if_needed() {
  if have_cmd flamegraph.pl && have_cmd stackcollapse-perf.pl; then
    log "FlameGraph scripts already available in PATH."
    return 0
  fi

  if [[ -x /usr/share/flamegraph/flamegraph.pl && -x /usr/share/flamegraph/stackcollapse-perf.pl ]]; then
    log "Linking FlameGraph scripts from /usr/share/flamegraph to /usr/local/bin."
    run "${SUDO[@]}" ln -sf /usr/share/flamegraph/flamegraph.pl /usr/local/bin/flamegraph.pl
    run "${SUDO[@]}" ln -sf /usr/share/flamegraph/stackcollapse-perf.pl /usr/local/bin/stackcollapse-perf.pl
    return 0
  fi

  if [[ "$NO_FLAMEGRAPH_GIT" == "1" ]]; then
    warn "FlameGraph scripts not found and NO_FLAMEGRAPH_GIT=1; skipping GitHub install."
    return 0
  fi

  have_cmd git || {
    warn "git not found; cannot clone FlameGraph."
    return 0
  }

  log "Installing Brendan Gregg's FlameGraph scripts into ${FLAMEGRAPH_DIR}."
  if [[ -d "$FLAMEGRAPH_DIR/.git" ]]; then
    run "${SUDO[@]}" git -C "$FLAMEGRAPH_DIR" pull --ff-only
  else
    run "${SUDO[@]}" rm -rf "$FLAMEGRAPH_DIR"
    run "${SUDO[@]}" git clone --depth 1 https://github.com/brendangregg/FlameGraph.git "$FLAMEGRAPH_DIR"
  fi

  run "${SUDO[@]}" ln -sf "$FLAMEGRAPH_DIR/flamegraph.pl" /usr/local/bin/flamegraph.pl
  run "${SUDO[@]}" ln -sf "$FLAMEGRAPH_DIR/stackcollapse-perf.pl" /usr/local/bin/stackcollapse-perf.pl
}

maybe_relax_perf_sysctl() {
  if [[ "$RELAX_PERF_SYSCTL" != "1" ]]; then
    log "Leaving kernel perf restrictions unchanged. Set RELAX_PERF_SYSCTL=1 to change them."
    return 0
  fi

  warn "RELAX_PERF_SYSCTL=1: lowering profiling restrictions on this machine."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" <<'SYSCTL_EOF'
# Installed by install_matlab_debug_tools.zsh
# Easier local profiling/debugging; less restrictive than Ubuntu defaults.
# Remove this file and run `sudo sysctl --system` to revert.
kernel.perf_event_paranoid = 1
kernel.kptr_restrict = 0
SYSCTL_EOF

  run "${SUDO[@]}" install -m 0644 "$tmp" /etc/sysctl.d/99-matlab-profiling.conf
  rm -f "$tmp"
  run "${SUDO[@]}" sysctl --system
}

verify_tools() {
  log "Verifying commands..."

  local -a commands=(
    zsh
    systemctl
    timeout
    strace
    perf
    bpftrace
    ps
    top
    journalctl
    lsof
    gdb
    eu-stack
    trace-cmd
    pidstat
    iostat
    flamegraph.pl
    stackcollapse-perf.pl
  )

  local cmd path
  for cmd in "${commands[@]}"; do
    if path=$(command -v "$cmd" 2>/dev/null); then
      printf '  %-24s %s\n' "$cmd" "$path"
    else
      printf '  %-24s %s\n' "$cmd" "MISSING"
    fi
  done

  print
  log "Kernel / perf-related settings:"
  for f in \
    /proc/sys/kernel/perf_event_paranoid \
    /proc/sys/kernel/kptr_restrict \
    /proc/sys/kernel/unprivileged_bpf_disabled; do
    if [[ -r "$f" ]]; then
      printf '  %-45s %s\n' "$f" "$(<"$f")"
    fi
  done

  print
  log "Quick smoke tests:"
  if have_cmd perf; then
    run perf --version || warn "perf exists but returned an error. This can happen if linux-tools for the running kernel are missing."
  else
    warn "perf command not found. Try installing linux-tools-${KERNEL_RELEASE} or the matching linux-tools package for your kernel flavor."
  fi

  if have_cmd bpftrace; then
    run bpftrace --version || warn "bpftrace exists but returned an error."
  else
    warn "bpftrace command not found."
  fi
}

main() {
  cat <<HEADER
${SCRIPT_NAME}
Kernel: ${KERNEL_RELEASE}
DRY_RUN=${DRY_RUN} NO_APT_UPDATE=${NO_APT_UPDATE} NO_FLAMEGRAPH_GIT=${NO_FLAMEGRAPH_GIT} RELAX_PERF_SYSCTL=${RELAX_PERF_SYSCTL}
HEADER

  require_apt_system
  require_sudo
  install_apt_packages
  install_flamegraph_from_git_if_needed
  maybe_relax_perf_sysctl
  verify_tools

  cat <<'FOOTER'

Done.

Recommended next step:
  chmod +x matlab_hang_capture.zsh
  ./matlab_hang_capture.zsh theConductor.service 60

If perf still fails, the most common cause is that the exact linux-tools package
for the running kernel is unavailable from the enabled Ubuntu repositories.
Check:
  uname -r
  apt-cache policy linux-tools-$(uname -r)
  perf --version

If bpftrace complains about permissions, run the MATLAB collector with sudo-enabled
commands as written. For persistent relaxed settings on a trusted workstation, rerun:
  RELAX_PERF_SYSCTL=1 ./install_matlab_debug_tools.zsh
FOOTER
}

main "$@"
