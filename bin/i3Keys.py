#!/usr/bin/env python3
from __future__ import annotations

import html
import subprocess
import sys
from typing import List, Tuple


def escape_markup(value: str) -> str:
	"""HTML-escape strings for rofi markup."""
	return html.escape(value, quote=True)


def collect_bindings() -> List[Tuple[str, str]]:
	"""Return (key, command) tuples parsed from the current i3 config."""
	try:
		config = subprocess.check_output(["i3-msg", "-t", "get_config"], text=True)
	except (OSError, subprocess.CalledProcessError) as err:
		raise SystemExit(f"Failed to read i3 config: {err}") from err

	bindings: List[Tuple[str, str]] = []
	for line in config.splitlines():
		line = line.strip()
		if not line or line.startswith("#") or not line.startswith("bindsym "):
			continue
		entry = line[len("bindsym ") :]
		try:
			key, cmd = entry.split(maxsplit=1)
		except ValueError:
			continue
		bindings.append((key, cmd))
	return bindings


def build_rofi_payload(bindings: List[Tuple[str, str]]) -> bytes:
	"""Prepare the nul-separated payload for rofi."""
	parts: List[str] = []
	for key, cmd in bindings:
		markup_key = f"<span size='large' weight='heavy'>{escape_markup(key)}</span>"
		markup_cmd = f"\t\t{escape_markup(cmd)}"
		parts.append(f"{markup_key}\n{markup_cmd}\0")
	return "".join(parts).encode("utf-8")


def prompt_with_rofi(payload: bytes) -> Tuple[int, int]:
	"""Send payload to rofi and return (exit_code, selected_index)."""
	try:
		proc = subprocess.Popen(
			[
				"rofi",
				"-dmenu",
				"-p",
				"i3 keybindings",
				"-sep",
				r"\0",
				"-eh",
				"2",
				"-markup-rows",
				"-format",
				"i",
			],
			stdin=subprocess.PIPE,
			stdout=subprocess.PIPE,
			stderr=sys.stderr,
		)
	except OSError as err:
		raise SystemExit(f"Failed to launch rofi: {err}") from err

	stdout_data, _ = proc.communicate(payload)
	exit_code = proc.returncode
	selected = stdout_data.decode("utf-8").strip()
	index = int(selected) if selected.isdigit() else -1
	return exit_code, index


def execute_binding(cmd: str) -> None:
	try:
		subprocess.run(["i3-msg", cmd], check=True)
	except (OSError, subprocess.CalledProcessError) as err:
		raise SystemExit(f"Failed to execute i3 command '{cmd}': {err}") from err


def main() -> None:
	bindings = collect_bindings()
	if not bindings:
		raise SystemExit("No bindings found.")

	payload = build_rofi_payload(bindings)
	exit_code, index = prompt_with_rofi(payload)

	if exit_code != 0 or index < 0 or index >= len(bindings):
		print(f"EXIT: {exit_code}", file=sys.stderr)
		return

	cmd = bindings[index][1]
	print(f"STDOUT: [{index}] => [{cmd}]", file=sys.stderr)
	execute_binding(cmd)


if __name__ == "__main__":
	main()
