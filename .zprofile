[[ -d "/opt/homebrew/bin" ]] && path=("/opt/homebrew/bin" $path)
[[ -d "$HOME/.pixi/bin" ]] && path=("$HOME/.pixi/bin" $path)
export path