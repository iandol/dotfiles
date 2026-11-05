#!/usr/bin/env python3
from __future__ import annotations

import html
import json
import os
import shutil
import subprocess
import sys
from typing import List, Tuple


def ipc_tool() -> str:
	"""Pick the IPC client for the running compositor (sway or i3)."""
	if os.environ.get("SWAYSOCK") and shutil.which("swaymsg"):
		return "swaymsg"
	if os.environ.get("I3SOCK") and shutil.which("i3-msg"):
		return "i3-msg"
	# No IPC socket in the environment: guess from the session type so a
	# machine with both sway and i3 installed picks the right client.
	if os.environ.get("WAYLAND_DISPLAY") and shutil.which("swaymsg"):
		return "swaymsg"
	if os.environ.get("DISPLAY") and shutil.which("i3-msg"):
		return "i3-msg"
	for candidate in ("swaymsg", "i3-msg"):
		if shutil.which(candidate):
			return candidate
	return "i3-msg"


def collect_bindings() -> List[Tuple[str, str]]:
	"""Return (key, command) tuples parsed from the compositor config."""
	tool = ipc_tool()
	try:
		raw = subprocess.check_output([tool, "-t", "get_config"], text=True)
	except (OSError, subprocess.CalledProcessError) as err:
		raise SystemExit(f"Failed to read config via {tool}: {err}") from err

	# Both i3-msg and swaymsg wrap the config in JSON: {"config": "..."}
	try:
		config = json.loads(raw)["config"]
	except (ValueError, KeyError, TypeError):
		config = raw

	bindings: List[Tuple[str, str]] = []
	for line in config.splitlines():
		line = line.strip()
		if not line.startswith("bindsym "):
			continue
		tokens = line[len("bindsym ") :].split()
		# Drop binding flags such as --locked / --to-code / --whole-window.
		while tokens and tokens[0].startswith("--"):
			tokens.pop(0)
		if len(tokens) < 2:
			continue
		bindings.append((tokens[0], " ".join(tokens[1:])))
	return bindings


def build_rofi_payload(bindings: List[Tuple[str, str]]) -> bytes:
	"""Prepare the nul-separated payload for rofi."""
	parts: List[str] = []
	for key, cmd in bindings:
		markup_key = f"<span size='large' weight='heavy'>{escape_markup(key)}</span>"
		markup_cmd = f"\t\t{escape_markup(cmd)}"
		parts.append(f"{markup_key}\n{markup_cmd}\0")
	return "".join(parts).encode("utf-8")


def escape_markup(value: str) -> str:
	"""HTML-escape strings for rofi markup."""
	return html.escape(value, quote=True)


def prompt_with_rofi(payload: bytes) -> Tuple[int, int]:
	"""Send payload to rofi and return (exit_code, selected_index)."""
	try:
		proc = subprocess.Popen(
			[
				"rofi",
				"-dmenu",
				"-p",
				"keybindings",
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
	tool = ipc_tool()
	try:
		subprocess.run([tool, cmd], check=True)
	except (OSError, subprocess.CalledProcessError) as err:
		raise SystemExit(f"Failed to execute '{cmd}' via {tool}: {err}") from err


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
