#!/usr/bin/env zsh

ARCHIVE_PATH="${HOME}/Downloads/tools.7z"
DECOMPRESS_ONLY=0
TRACKED_PATHS=(
	"/usr/local/bin/eget"
	"/usr/local/bin/mediamtx"
	"${HOME}/.local/bin/cogmoteGO"
	"/usr/local/bin/rotz"
	"/usr/local/bin/mihomo"
	"/usr/local/bin/mihomosh"
	"${HOME}/Downloads/nomachine.deb"
	"${HOME}/Downloads/clash.deb"
	"/usr/local/bin/elvish"
)

usage() {
	cat <<'EOF' >&2
Usage: makeTools.sh [-d]
	-d  Decompress ~/Downloads/tools.7z back to its original locations
EOF
	exit 2
}

while getopts ":d" opt; do
	case "${opt}" in
		d) DECOMPRESS_ONLY=1 ;;
		*) usage ;;
	esac
done
shift $((OPTIND - 1))

cd ~ || exit

if (( DECOMPRESS_ONLY )); then
	if [[ ! -f "${ARCHIVE_PATH}" ]]; then
		echo "Archive not found: ${ARCHIVE_PATH}" >&2
		exit 1
	fi
	tmp_dir="$(mktemp -d)" || exit 1
	trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
	echo "Extracting ${ARCHIVE_PATH} to temporary dir: ${tmp_dir}"
	7z x -aoa "${ARCHIVE_PATH}" -o"${tmp_dir}" >/dev/null

	restore_one() {
		local dest="$1"
		local rel="${dest#/}"
		local base_name
		base_name="$(basename "$dest")"
		local src="${tmp_dir}/${rel}"
		if [[ ! -f "$src" ]]; then
			local alt="${tmp_dir}/${base_name}"
			if [[ -f "$alt" ]]; then
				src="$alt"
			else
				local found
				found="$(find "$tmp_dir" -type f -name "$base_name" -print -quit 2>/dev/null)"
				if [[ -n "$found" ]]; then
					src="$found"
				else
					echo "Missing ${rel} in archive; skipping ${dest}" >&2
					return
				fi
			fi
		fi
		mkdir -p "$(dirname "$dest")"
		cp -f "$src" "$dest"
		chmod --reference="$src" "$dest" 2>/dev/null || true
		chown --reference="$src" "$dest" 2>/dev/null || true
		printf 'Restored %s\n' "$dest"
	}

	for target in "${TRACKED_PATHS[@]}"; do
		restore_one "$target"
	done

	echo "Done. Rerun with sudo if you saw permission errors for /usr/local files."
	exit 0
fi

[[ ! -f ~/Downloads/nomachine.deb ]] && curl -L -o ~/Downloads/nomachine.deb https://web9001.nomachine.com/download/9.2/Linux/nomachine_9.2.18_3_amd64.deb

~/.dotfiles/bin/egetAll.sh

for tracked in "${TRACKED_PATHS[@]}"; do
	if [[ ! -e "$tracked" ]]; then
		echo "Skipping missing file: $tracked" >&2
		continue
	fi
	7z u "${ARCHIVE_PATH}" "$tracked"
done

