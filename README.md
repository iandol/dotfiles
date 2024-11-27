---
title: Dot Files
---

# Dot Files

I work on macOS / Ubuntu / Raspberry Pi OS / occasionally Windows+WSL, so need to tweak my dotfiles for each. I symlink files to their respective locations, I probably should use a dotfiles manager but it would probably take longer to restructure my dotfiles, so `ln -s` using [makeLinks.sh](./makeLinks.sh) is fine for now.

My favourite interactive shell is [Elvish](https://elv.sh) — with a fallback to `zsh`. Elvish is a simple and elegant shell programming language, much easier with far less legacy complexity and cruft compared to `zsh` or `bash`. Nice interactive features out-of-the-box. My elvish modules are here: [github.com/iandol/elvish-modules](https://github.com/iandol/elvish-modules)

For Elvish I add the [Starship](https://starship.rs) prompt, use [Carapace](https://github.com/carapace-sh/carapace-bin) for command completion, and [X-Cmd 文](https://www.x-cmd.com) as an all-in-one shell helper (it is fast and a great way to discover/test new shell tools). I manage Ruby / Python and some other tools with [pixi](https://pixi.sh/latest/) (see [pixi-global.toml](configs/pixi-global.toml)), and other packages with [Homebrew](https://brew.sh) and [X-Cmd 文](https://www.x-cmd.com) (x-cmd integrates with `brew` and `pixi` as well as offering its own packages).

My preferred terminal is [Kitty](https://sw.kovidgoyal.net/kitty/overview/), so many helpful features, cross-platform and fast (sadly some bugs on RPi). Install with brew on macOS and the `installKitty` alias for Linux.

I use [nvim](https://neovim.io) for most editing *in* the terminal, but basically treat it like vim and my vim skills are basic. I use VSCode for GUI editing (though it is slow on the RPi).
