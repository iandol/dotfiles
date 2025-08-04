# Dot Files

> The main repository is: [codeberg.org/iandol/dotfiles](https://codeberg.org/iandol/dotfiles)

I work on macOS / Ubuntu / Raspberry Pi OS / occasionally Windows 11 (WSL or msys2), so need to tweak my dotfiles for each. I symlink files to their respective locations, using [`rotz`](https://github.com/volllly/rotz) as my dotfiles manager, with [makeLinks.sh](./makeLinks.sh) as my previous solution.

My *favourite interactive shell* is [**_Elvish_**](https://elv.sh) — with a fallback to `zsh`. `elvish` is a simple and elegant shell programming language, easier with far less legacy complexity and cruft compared to POSIX shells. Nice interactive features out-of-the-box. My elvish modules are here: [iandol/elvish-modules](https://github.com/iandol/elvish-modules)

My preferred terminal is [Kitty](https://sw.kovidgoyal.net/kitty/overview/), so many helpful features, cross-platform and fast. Installed with Homebrew on macOS and my `installKitty` `elvish`/`zsh` alias for Linux.

## Main shell tools: 

* [`carapace`](https://github.com/carapace-sh/carapace-bin) awesome cross-shell command completion.
* [`pixi`](https://pixi.sh/latest/): cross-platform packager manager to install most core tools (see [pixi-global.toml](tools/pixi-global.toml)). _Note: Lua is static, which doesn't work well when remote debugging._
* [`brew`](https://brew.sh) for packages not available in `pixi`; and casks are awesome (e.g. for installing fonts on macOS AND Linux)! 
* [`x` X-Cmd 文](https://www.x-cmd.com) as an all-in-one shell helper (it is fast and a great way to discover/test new shell tools). I love that it makes everything discoverable. Note: x-cmd integrates with `brew` and `pixi` as well as offering its own packages.
* [`starship`](https://starship.rs) for the prompt.
* [`neovim`](https://neovim.io) for most editing *in* the terminal, though my vim skills are really basic. I use VSCode for GUI editing (though it is sloooow on the RPi). I use the lazy.nvim plugin manager.  
* [`eza`](https://github.com/eza-community/eza) to replace ls.
* [`bat`](https://github.com/sharkdp/bat) to replace cat.
* [`zoxide`](https://github.com/ajeetdsouza/zoxide) to replace cd.
* [`fd`](https://github.com/sharkdp/fd) to find files.
* [`ripgrep`](https://github.com/BurntSushi/ripgrep) to grep.
* [`sd`](https://github.com/chmln/sd) to sed with simpler syntax.
* [`lazygit`]() to visually git.
* [`dua`](https://github.com/byfd/dua) to du.
* [`jq`](https://stedolan.github.io/jq/) and [yq](https://github.com/mikefarah/yq) to json/yaml.
* [`pandoc`](https://github.com/jgm/pandoc), [`typst`](https://github.com/typst/typst) or [`quarto`](https://quarto.org) to write.