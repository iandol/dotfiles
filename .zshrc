# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"
# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"
# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"
# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"
# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

export ZSHA_BASE="$HOME/.antigen"
export DF_BASE="$HOME/.dotfiles"

source "$ZSHA_BASE/antigen.zsh"
antigen use oh-my-zsh
antigen bundles <<EOBUNDLES
	nyan
	marked2
	history
	command-not-found
	zsh-users/zsh-syntax-highlighting
	zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
EOBUNDLES
#antigen theme smt
antigen theme mashaal/wild-cherry zsh/wild-cherry.zsh-theme
antigen apply

export EDITOR='subl -w'
export MANPAGER='less -X' # don't clear after quitting man
DIRSTACKSIZE=12 # pushd stacksize
setopt autopushd pushdminus pushdsilent

[[ -d "/Volumes/Mac/Users/ian/" ]] && MYHD='/Volumes/Mac/Users/ian/' # old external HD
#[[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/" ]] && export MATLAB_JAVA="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home" # use installed JAVA
#[[ -d "/usr/local/share/zsh-completions/" ]] && fpath=(/usr/local/share/zsh-completions $fpath)
[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path) # MacTeX
[[ -d "/Applications/MATLAB_R2017b.app/bin/" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2017b.app/bin/matlab" && path=("/Applications/MATLAB_R2017b.app/bin" $path) # matlab
[[ -f "/Applications/MATLAB_R2017b.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2017b.app/bin/maci64/mlint" ~/bin/mlint # matlab
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
  source $HOME/miniconda3/etc/profile.d/conda.sh # anaconda scientific python
elif [[ -d "$HOME/miniconda3/" ]]; then
  path=("$HOME/miniconda3/bin" $path) 
elif [[ -d "$HOME/anaconda3/" ]]; then
  path=("$HOME/anaconda3/bin" $path) 
fi
[[ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]] && path=("/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" $path)
[[ -d "/usr/local/sbin" ]] && path=("/usr/local/sbin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
export path

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # RVM shell *as function*
# export PATH="$PATH:$HOME/.rvm/bin"
[[ -f $(which swiftenv) ]] && eval "$(swiftenv init -)"
[[ -f $(which rbenv) ]] && eval "$(rbenv init -)"
[[ -f $(which archey) ]] && archey -c -o
#[[ -f $(which ansiweather) ]] && ansiweather
[[ -e "$DF_BASE/aliases" ]] && source "$DF_BASE/aliases"

echo "💡:CTRL+w,k,u: 🔪 | CTRL+r|s: 🔍 | d, cd - & cd #: 🚀 | curl cheat.sh/?"
