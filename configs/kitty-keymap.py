#!/usr/bin/env python3
"""Kitten to print the current list of keyboard shortcuts (consists of BOTH single keys and key
sequences).
"""

import re
from collections import defaultdict
from collections.abc import Sequence
from typing import Final, Union, TypeAlias

from kittens.tui.handler import result_handler
from kitty import fast_data_types
from kitty.boss import Boss
from kitty.options.types import Options as KittyOpts
from kitty.options.utils import KeyMap, KeyboardMode, KeyDefinition
from kitty.tab_bar import Formatter as fmt
from kitty.types import Shortcut, mod_to_names

# List of categories and regular expressions to match actions on
# Keyboard modes are categorized into their own category
categories = {
    "Scrolling": r"(^scroll_|show_scrollback|show_last_command_output)",
    "Tab Management": r"(^|_)tab(_|$)",
    "Window Management": r"(^|_)windows?(_|$)",
    "Layout Management": r"(^|_)layout(_|\b)",
    "Other Shortcuts": r".",
    # "Mode (xxx)": ...,
}

Shortcut2Defn: TypeAlias = dict[Shortcut, str]
ShortcutRepr: TypeAlias = str
ActionMap: TypeAlias = dict[str, list[ShortcutRepr]]


def main(args: list[str]) -> Union[str, None]:
    pass


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss):
    opts: KittyOpts = fast_data_types.get_options()

    output_categorized: dict[str, ActionMap] = defaultdict(lambda: defaultdict(list))
    for mode in opts.keyboard_modes.values():
        mode: KeyboardMode
        mode_name: str = mode.name or "default"
        mode_keymap: KeyMap = mode.keymap

        # set up keymaps (single keystrokes) + key sequences (combinations of keystrokes)
        key_mappings: Shortcut2Defn = {}
        for key, definitions in mode_keymap.items():
            # key: SingleKey
            definitions: Sequence[KeyDefinition]

            for defn in definitions:
                action = defn.human_repr()
                if defn.is_sequence:
                    key_mappings[Shortcut((defn.trigger,) + defn.rest)] = action
                else:
                    key_mappings[Shortcut((key,))] = action

        # categorize the default mode shortcuts
        # because each action can have multiple shortcuts associated with it, we also attempt to
        # group shortcuts with the same actions together.
        for key, action in key_mappings.items():
            key_repr: ShortcutRepr = key.human_repr(kitty_mod=opts.kitty_mod)
            key_repr = f"{key_repr:<18} {fmt.fg.red}→{fmt.fg.default}"
            if match := re.search(r"^push_keyboard_mode (\w+)$", action):
                # bold the mode name if found
                action_fmt = (
                    f"push_keyboard_mode {fmt.bold}{match.group(1)}{fmt.nobold}"
                )
                key_repr = f"{key_repr} {action_fmt}"
            else:
                key_repr = f"{key_repr} {action}"

            if mode_name != "default":
                mn = f"Mode {mode_name}"
                categories[mn] = 'None'  # register this mode as a valid "category"
                output_categorized[mn][action].append(key_repr)
                continue

            for subheader, re_pat in categories.items():
                if re.search(re_pat, action):
                    action_map: ActionMap = output_categorized[subheader]
                    action_map[action].append(key_repr)
                    break
            else:
                emsg = f"No valid subheader found for keymap {key_repr!r}."
                raise ValueError(emsg)

    # print out shortcuts
    output = [
        "=======================",
        "Kitty keyboard mappings",
        "=======================",
        "",
        "My kitty_mod is {}.".format("+".join(mod_to_names(opts.kitty_mod))),
        "",
    ]
    for category in categories:
        if category not in output_categorized:
            continue
        output.extend([f"{fmt.bold}{category}{fmt.nobold}", "=" * len(category), ""])
        output.extend(sum(output_categorized[category].values(), []))
        output.append("")

    boss.display_scrollback(
        boss.active_window,
        "\n".join(output),
        title="Kitty keyboard mappings",
        report_cursor=False,
    )