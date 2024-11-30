# Dot Files

The main repository is at <https:codeberg.org/iandol/dotfiles> 

I work on macOS / Ubuntu / Raspberry Pi OS / occasionally Windows 11 (WSL or msys2), so need to tweak my dotfiles for each. I symlink files to their respective locations, I probably should use a dotfiles manager but it would probably take longer to restructure my dotfiles, so `ln -s` using [makeLinks.sh](./makeLinks.sh) is fine for now.

My favourite interactive shell is [**_Elvish_**](https://elv.sh) — with a fallback to `zsh`. `elvish` is a simple and elegant shell programming language, much easier with far less legacy complexity and cruft compared to POSIX shells. Nice interactive features out-of-the-box. My elvish modules are here: [iandol/elvish-modules](https://github.com/iandol/elvish-modules)

For Elvish I add: 

* [Starship](https://starship.rs) prompt
* [Carapace](https://github.com/carapace-sh/carapace-bin) for command completion
* [X-Cmd 文](https://www.x-cmd.com) as an all-in-one shell helper (it is fast and a great way to discover/test new shell tools). 
* [pixi](https://pixi.sh/latest/) to install Ruby, Python and other tools cross-platform (see [pixi-global.toml](configs/pixi-global.toml)). _Note: Lua install is static, which doesn't work well when debugging._
* [Homebrew](https://brew.sh) and [X-Cmd 文](https://www.x-cmd.com) for everything else, and macOS casks are awesome! Note: x-cmd integrates with `brew` and `pixi` as well as offering its own packages.

My preferred terminal is [Kitty](https://sw.kovidgoyal.net/kitty/overview/), so many helpful features, cross-platform and fast (sadly some bugs on RPi). Install with Homebrew on macOS and my `installKitty` `elvish`/`zsh` alias for Linux.

I use [nvim](https://neovim.io) for most editing *in* the terminal, but basically treat it like vim and my vim skills are really basic. I use VSCode for GUI editing (though it is sloooow on the RPi).

## Other alterative tools

* [eza](https://github.com/eza-community/eza) to replace ls
* [bat](https://github.com/sharkdp/bat) to replace cat
* [fd](https://github.com/sharkdp/fd) to find files
* [ripgrep](https://github.com/BurntSushi/ripgrep) to grep
* [sd](https://github.com/chmln/sd) to sed with simpler syntax
* [dua](https://github.com/byfd/dua) to du
* [jq](https://stedolan.github.io/jq/) and [yq](https://github.com/mikefarah/yq) to json/yaml
* [pandoc](https://github.com/jgm/pandoc) > [typst](https://github.com/typst/typst) or [quarto](https://quarto.org) to write