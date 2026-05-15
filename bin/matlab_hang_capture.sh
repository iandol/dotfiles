#!/usr/bin/env zsh
# matlab_hang_capture.zsh
# Collect low-level diagnostics from a hung MATLAB process managed by a user systemd service.
# Default service: theConductor.service
# Default duration per active profiler: 60 seconds

emulate -L zsh
set -e
set -u
set -o pipefail
setopt NULL_GLOB

SERVICE="${1:-theConductor.service}"
DURATION="${2:-60}"
OUTROOT="${OUTROOT:-$HOME/debug}"
RUNSTAMP="$(date +%Y%m%d_%H%M%S)"
RUNDIR="${OUTROOT}/matlab_hang_${RUNSTAMP}"
LOG="${RUNDIR}/collector.log"

# Set ENABLE_GDB=1 when you want a native thread backtrace.
# This briefly stops the process while gdb attaches, so it is off by default.
ENABLE_GDB="${ENABLE_GDB:-0}"

# Set ENABLE_COREDUMP=1 only if you explicitly want a full gcore dump.
# A MATLAB core can be very large and gcore freezes the process while dumping.
ENABLE_COREDUMP="${ENABLE_COREDUMP:-0}"

mkdir -p "$RUNDIR"

log() {
  print -r -- "[$(date '+%F %T')] $*" | tee -a "$LOG"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

run_out() {
  local name="$1"
  shift
  local outfile="${RUNDIR}/${name}.txt"
  local rc=0
  {
    print -r -- "# $*"
    print -r -- "# started: $(date '+%F %T')"
    "$@" || rc=$?
    print -r -- "# exit_status: $rc"
    print -r -- "# ended: $(date '+%F %T')"
  } >"$outfile" 2>&1 || true
}

run_shell() {
  local name="$1"
  shift
  local cmd="$*"
  local outfile="${RUNDIR}/${name}.txt"
  local rc=0
  {
    print -r -- "# $cmd"
    print -r -- "# started: $(date '+%F %T')"
    eval "$cmd" || rc=$?
    print -r -- "# exit_status: $rc"
    print -r -- "# ended: $(date '+%F %T')"
  } >"$outfile" 2>&1 || true
}

need() {
  if ! have "$1"; then
    log "WARNING: missing command: $1"
    print -r -- "$1" >> "${RUNDIR}/missing_commands.txt"
    return 1
  fi
}

collect_proc_thread_snapshot() {
  local label="$1"
  local outfile="${RUNDIR}/proc_threads_${label}.txt"
  {
    print -r -- "# Thread snapshot: $label"
    print -r -- "# PID: $PID"
    print -r -- "# Time: $(date '+%F %T')"
    print -r -- ""

    for taskdir in /proc/${PID}/task/*(N); do
      local tid="${taskdir:t}"
      print -r -- "================================================================================"
      print -r -- "TID: $tid"
      print -n -- "comm: "; cat "${taskdir}/comm" 2>/dev/null || true
      print -n -- "wchan: "; cat "${taskdir}/wchan" 2>/dev/null || true
      print -n -- "syscall: "; cat "${taskdir}/syscall" 2>/dev/null || true
      print -r -- "-- status excerpt --"
      egrep '^(Name|State|Tgid|Pid|PPid|TracerPid|Threads|voluntary_ctxt_switches|nonvoluntary_ctxt_switches):' "${taskdir}/status" 2>/dev/null || true
      print -r -- "-- sched excerpt --"
      egrep '^(se\.exec_start|se\.vruntime|se\.sum_exec_runtime|nr_switches|nr_voluntary_switches|nr_involuntary_switches|se\.load|policy|prio)' "${taskdir}/sched" 2>/dev/null || true
      print -r -- "-- kernel stack --"
      sudo cat "${taskdir}/stack" 2>/dev/null || true
      print -r -- ""
    done
  } >"$outfile" 2>&1 || true
}

write_readme() {
  cat > "${RUNDIR}/README.txt" <<EOF_README
MATLAB hang diagnostic capture
==============================

Service:     ${SERVICE}
Main PID:    ${PID}
Duration:    ${DURATION} seconds per active profiler
Started:     ${RUNSTAMP}
Host:        $(hostname)
Kernel:      $(uname -a)
Output dir:  ${RUNDIR}

Important files
---------------
collector.log                    Progress log from this script.
metadata.txt                     Host, user, kernel, uptime metadata.
systemd-show.txt                 systemctl --user show output for the service.
systemd-status.txt               systemctl --user status output.
journal-user-service.txt          Recent user journal for the service.
ps-main.txt / ps-threads.txt      Process and thread table snapshots.
proc_status.txt                  /proc/PID/status.
proc_threads_before.txt           Per-thread state, syscall, wait channel, and kernel stack before active tracing.
proc_threads_after.txt            Same after active tracing.
matlab.strace                    60 s syscall trace: timing, duration, thread/fork following, fd/path decoding.
perf.data                        Raw perf recording.
perf.script.txt                  Decoded perf samples.
perf.report.txt                  Text perf report.
flamegraph.html or flamegraph.svg Flamegraph if your perf or FlameGraph scripts support it.
bpftrace-ustacks.txt             60 s sampled user/kernel stacks via bpftrace.
bpftrace-syscalls.txt            60 s syscall count aggregation via bpftrace.
top-threads.txt                  top -H thread-level sampling.
pidstat.txt                      pidstat thread CPU/memory/IO/context-switch sampling, if sysstat is installed.
lsof.txt / proc_fd.txt            Open files and descriptors.
dmesg-tail.txt                   Recent kernel messages.

Notes
-----
1. strace attaches with ptrace and can perturb timing. Use it when the process is already hung.
2. perf is usually less intrusive than strace and is useful when MATLAB is burning CPU in native code or a library.
3. bpftrace stack capture may need kernel settings that allow BPF/perf events. Running with sudo is intentional.
4. ENABLE_GDB=1 adds a native all-thread gdb backtrace. ENABLE_COREDUMP=1 adds a full gcore dump; this may be huge.
EOF_README
}

log "Creating diagnostic folder: $RUNDIR"

# Sanity checks.
need systemctl || exit 1
need sudo || exit 1
need timeout || exit 1

PID_RAW="$(systemctl --user show "$SERVICE" --property=MainPID --value 2>/dev/null || true)"
PID="$(print -r -- "$PID_RAW" | tr -dc '0-9')"

if [[ -z "$PID" || "$PID" == "0" ]]; then
  log "ERROR: could not find a non-zero MainPID for user service: $SERVICE"
  run_out systemd-show systemctl --user show "$SERVICE"
  exit 1
fi

if [[ ! -d "/proc/$PID" ]]; then
  log "ERROR: PID $PID from $SERVICE does not exist under /proc. The process may have exited."
  exit 1
fi

log "Found MainPID=$PID for $SERVICE"

# Sudo credentials up-front, so the later 60-second captures do not stall on a password prompt.
log "Refreshing sudo credentials"
sudo -v

write_readme

# Metadata and service logs.
run_shell metadata 'date; hostnamectl 2>/dev/null || hostname; uname -a; uptime; id; whoami; pwd; print -r -- "SHELL=${SHELL:-}"; print -r -- "PATH=${PATH:-}"'
run_out systemd-show systemctl --user show "$SERVICE"
run_out systemd-status systemctl --user status "$SERVICE" --no-pager --lines=200
run_out journal-user-service journalctl --user -u "$SERVICE" --no-pager --since "2 hours ago"
run_out ps-main ps -fp "$PID"
run_out ps-threads ps -L -o pid,tid,ppid,psr,stat,pcpu,pmem,etime,time,wchan:32,comm,args -p "$PID"
run_out proc-status cat "/proc/${PID}/status"
run_out proc-limits cat "/proc/${PID}/limits"
run_out proc-sched cat "/proc/${PID}/sched"
run_out proc-wchan cat "/proc/${PID}/wchan"
run_out proc-syscall cat "/proc/${PID}/syscall"
run_out proc-smaps-rollup sudo cat "/proc/${PID}/smaps_rollup"
run_shell proc-exe-cwd-root "ls -l /proc/${PID}/exe /proc/${PID}/cwd /proc/${PID}/root 2>&1 || true"
run_shell proc-fd "sudo ls -la /proc/${PID}/fd 2>&1 || true"
run_shell proc-maps "sudo cat /proc/${PID}/maps 2>&1 || true"

if have pstree; then
  run_out pstree pstree -pal "$PID"
fi

if have pmap; then
  run_out pmap pmap -x "$PID"
fi

if have lsof; then
  run_out lsof sudo lsof -nP -p "$PID"
else
  log "lsof not found; proc_fd.txt still contains descriptor links."
fi

collect_proc_thread_snapshot before

# A lightweight system snapshot while MATLAB is hung.
if have vmstat; then
  log "Running vmstat for ${DURATION}s"
  run_out vmstat vmstat 1 "$DURATION"
fi

if have top; then
  log "Running top -H for ${DURATION}s"
  run_out top-threads top -H -b -d 1 -n "$DURATION" -p "$PID"
fi

if have pidstat; then
  log "Running pidstat for ${DURATION}s"
  run_out pidstat pidstat -p "$PID" -t -d -r -u -w 1 "$DURATION"
else
  log "pidstat not found; install sysstat if you want pidstat thread/IO samples."
fi

# strace: syscall-level view. INT lets strace detach cleanly on timeout.
if have strace; then
  log "Running strace for ${DURATION}s"
  {
    rc=0
    print -r -- "# sudo timeout --foreground -s INT -k 5s ${DURATION}s strace -p ${PID} -f -tt -T -yy -s 256 -o ${RUNDIR}/matlab.strace"
    sudo timeout --foreground -s INT -k 5s "${DURATION}s" \
      strace -p "$PID" -f -tt -T -yy -s 256 -o "${RUNDIR}/matlab.strace" || rc=$?
    print -r -- "# exit_status: $rc"
  } >"${RUNDIR}/strace-run.txt" 2>&1 || true
else
  log "strace not found; skipping strace capture."
fi

# perf: sampled CPU stacks.
if have perf; then
  log "Running perf record for ${DURATION}s"
  {
    rc=0
    print -r -- "# sudo perf record -F 99 --call-graph dwarf,16384 -p ${PID} -o ${RUNDIR}/perf.data -- sleep ${DURATION}"
    sudo perf record -F 99 --call-graph dwarf,16384 -p "$PID" -o "${RUNDIR}/perf.data" -- sleep "$DURATION" || rc=$?
    print -r -- "# exit_status: $rc"
  } >"${RUNDIR}/perf-record.txt" 2>&1 || true

  if [[ -s "${RUNDIR}/perf.data" ]]; then
    log "Generating perf script/report text files"
    sudo perf script -i "${RUNDIR}/perf.data" --header > "${RUNDIR}/perf.script.txt" 2> "${RUNDIR}/perf.script.stderr" || true
    sudo perf report -i "${RUNDIR}/perf.data" --stdio > "${RUNDIR}/perf.report.txt" 2> "${RUNDIR}/perf.report.stderr" || true

    log "Trying perf's built-in flamegraph script"
    (
      cd "$RUNDIR"
      sudo perf script report flamegraph > flamegraph.perf.stdout 2> flamegraph.perf.stderr
    ) || true

    # Some perf versions write flamegraph.html in the current directory; others need Brendan Gregg's scripts.
    if [[ ! -s "${RUNDIR}/flamegraph.html" ]]; then
      if have stackcollapse-perf.pl && have flamegraph.pl; then
        log "Trying FlameGraph stackcollapse-perf.pl + flamegraph.pl fallback"
        sudo perf script -i "${RUNDIR}/perf.data" 2> "${RUNDIR}/perf.script-for-svg.stderr" \
          | stackcollapse-perf.pl 2> "${RUNDIR}/stackcollapse.stderr" \
          | flamegraph.pl > "${RUNDIR}/flamegraph.svg" 2> "${RUNDIR}/flamegraph.svg.stderr" || true
      else
        log "No flamegraph.html produced, and stackcollapse-perf.pl/flamegraph.pl not found. perf.script.txt and perf.report.txt were still generated."
      fi
    fi
  else
    log "perf.data is missing or empty; see perf-record.txt"
  fi
else
  log "perf not found; skipping perf capture."
fi

# bpftrace: sampled stacks and syscall aggregation.
if have bpftrace; then
  log "Running bpftrace user/kernel stack profiler for ${DURATION}s"
  BPF_STACKS="profile:hz:99 /pid == ${PID}/ { @[ustack] = count(); @kernel[kstack] = count(); } END { print(@); print(@kernel); }"
  {
    rc=0
    print -r -- "# $BPF_STACKS"
    sudo timeout --foreground -s INT -k 5s "${DURATION}s" bpftrace -e "$BPF_STACKS" || rc=$?
    print -r -- "# exit_status: $rc"
  } > "${RUNDIR}/bpftrace-ustacks.txt" 2> "${RUNDIR}/bpftrace-ustacks.stderr" || true

  log "Running bpftrace syscall counter for ${DURATION}s"
  BPF_SYSCALLS="tracepoint:syscalls:sys_enter_* /pid == ${PID}/ { @[probe] = count(); } END { print(@); }"
  {
    rc=0
    print -r -- "# $BPF_SYSCALLS"
    sudo timeout --foreground -s INT -k 5s "${DURATION}s" bpftrace -e "$BPF_SYSCALLS" || rc=$?
    print -r -- "# exit_status: $rc"
  } > "${RUNDIR}/bpftrace-syscalls.txt" 2> "${RUNDIR}/bpftrace-syscalls.stderr" || true
else
  log "bpftrace not found; skipping bpftrace captures."
fi

# Optional intrusive native debugging.
if [[ "$ENABLE_GDB" == "1" ]]; then
  if have gdb; then
    log "ENABLE_GDB=1: collecting gdb all-thread backtrace"
    sudo gdb -p "$PID" -batch \
      -ex 'set pagination off' \
      -ex 'set confirm off' \
      -ex 'info threads' \
      -ex 'thread apply all bt' \
      -ex 'detach' \
      -ex 'quit' \
      > "${RUNDIR}/gdb-thread-backtrace.txt" 2>&1 || true
  else
    log "ENABLE_GDB=1 but gdb not found."
  fi
fi

if [[ "$ENABLE_COREDUMP" == "1" ]]; then
  if have gcore; then
    log "ENABLE_COREDUMP=1: collecting gcore dump. This can be very large."
    (
      cd "$RUNDIR"
      sudo gcore -o matlab_core "$PID"
    ) > "${RUNDIR}/gcore.txt" 2>&1 || true
  else
    log "ENABLE_COREDUMP=1 but gcore not found."
  fi
fi

collect_proc_thread_snapshot after

run_out ps-threads-after ps -L -o pid,tid,ppid,psr,stat,pcpu,pmem,etime,time,wchan:32,comm,args -p "$PID"
run_shell dmesg-tail "sudo dmesg -T --level=err,warn,crit,alert,emerg 2>&1 | tail -n 500"

# Make root-created files readable/writable by the invoking user.
log "Fixing ownership of output folder"
sudo chown -R "$(id -u):$(id -g)" "$RUNDIR" 2>/dev/null || true

log "Done. Diagnostic bundle is in: $RUNDIR"
print -r -- "$RUNDIR"
