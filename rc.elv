#==================================================== - ELVISH CONFIG
# elvish shell config: https://elv.sh/learn/tour.html
#====================================================

#==================================================== - BASE MODULES
use re
use str
use epm
use path
use math
use platform
use doc
if $platform:is-unix { use unix; edit:add-var unix: $unix: } 

#==================================================== - EXTERNAL MODULES
try { epm:install &silent-if-installed ^
	github.com/iandol/elvish-modules ^
	github.com/zzamboni/elvish-modules ^
	github.com/muesli/elvish-libs } catch { echo "Cannot install external modules..." }

use github.com/iandol/elvish-modules/cmds # my utility module
use github.com/iandol/elvish-modules/python # for python venv support
use github.com/iandol/elvish-modules/mamba # for conda/mamba support
use github.com/zzamboni/elvish-modules/bang-bang
use github.com/zzamboni/elvish-modules/spinners

#==================================================== - BASIC ENVIRONMENT
set-env XDG_CONFIG_HOME $E:HOME/.config
set-env XDG_DATA_HOME $E:HOME/.local/share
if $platform:is-windows { set-env HOME $E:USERPROFILE; set-env USER $E:USERNAME }

#==================================================== - IMPORT UTIL NAMES
var if-external~		= $cmds:if-external~
var append-to-path~		= $cmds:append-to-path~
var prepend-to-path~	= $cmds:prepend-to-path~
var do-if-path~			= $cmds:do-if-path~
var is-path~			= $cmds:is-path~
var is-file~			= $cmds:is-file~
var not-path~			= $cmds:is-path~
var not-file~			= $cmds:not-file~
var is-macos~			= $cmds:is-macos~
var is-linux~			= $cmds:is-linux~
var is-arm64~			= $cmds:is-arm64~
var mama~				= $mamba:activate~
var mamd~				= $mamba:deactivate~
var maml~				= $mamba:list~
var pya~				= $python:activate~
var pyd~				= $python:deactivate~
var pyl~				= $python:list-venvs~
set edit:completion:arg-completer[pya] = $edit:completion:arg-completer[python:activate]
set edit:completion:arg-completer[mama] = $edit:completion:arg-completer[mamba:activate]

#==================================================== - PATHS + VENVS
each {|p| prepend-to-path $p } [
	/Library/TeX/texbin
	~/scoop/apps/msys2/current/usr/bin
	/opt/local/bin
	~/.rbenv/shims
	~/.pyenv/shims
	~/scoop/shims
	/opt/homebrew/bin
	/home/linuxbrew/.linuxbrew/bin
	~/bin
	/usr/local/bin
	/usr/local/sbin
]
each {|p| append-to-path $p } [
	/usr/local/opt/python@3.10/libexec/bin
	/usr/local/opt/python@3.11/libexec/bin
	/Library/Frameworks/GStreamer.framework/Commands
]

var prefix; var suffix
if (is-macos) {
	set prefix = "/Applications/MATLAB_"; set suffix = ".app/bin"
} else {
	set prefix = "/usr/local/MATLAB/"; set suffix = "/bin"
}
var releases = [$prefix{R2023b R2023a R2022b R2022a R2021b R2021a R2020b R2020a}$suffix]
do-if-path $releases {|p|
	prepend-to-path $p
	set-env MATLAB_EXECUTABLE $p"/matlab" # matlab
	if (is-macos) { ln -sf $p"/maci64/mlint" ~/bin/mlint }
}

do-if-path $E:HOME/.venv/ {|p| set python:venv-directory = $p }
do-if-path [$E:HOME/micromamba /media/cog/data/micromamba] {|p| set mamba:root = $p; set-env MAMBA_ROOT_DIRECTORY $mamba:root }

#==================================================== - SETUP HOMEBREW
if-external brew {
	var pfix = (brew --prefix)
	echo (styled "…configuring "$platform:os"-"$platform:arch" brew… " bold italic yellow)
	set-env HOMEBREW_PREFIX $pfix
	set-env HOMEBREW_CELLAR $pfix'/Cellar'
	set-env HOMEBREW_REPOSITORY $pfix'/Homebrew'
	set-env MANPATH $pfix'/share/man:'$E:MANPATH
	set-env INFOPATH $pfix'/share/info:'$E:INFOPATH
	prepend-to-path $pfix'/bin'
	prepend-to-path $pfix'/sbin'
}

#==================================================== - KEY BINDINGS
set edit:insert:binding[Ctrl-a] = $edit:move-dot-sol~
set edit:insert:binding[Ctrl-e] = $edit:move-dot-eol~
set edit:insert:binding[Ctrl-b] = $cmds:external_edit_command~
#set edit:insert:binding[Ctrl-l] = { $edit:move-dot-eol~; $edit:kill-line-left~ }

#==================================================== - KITTY INTEGRATION
if (has-env KITTY_INSTALLATION_DIR) {
	fn osc {|c| print "\e]"$c"\a" }
	fn send-title {|t| osc '0;ɛ'$t }
	fn send-pwd { send-title (tilde-abbr $pwd | path:base (one)); osc '7;'(put $pwd)}
	set edit:before-readline = [ { send-pwd } { osc '133;A' } ]
	set edit:after-readline = [ {|c| send-title (str:split ' ' $c | take 1) } {|c| osc '133;C' } ]
	set after-chdir = [ {|_| send-pwd } ]
	echo (styled "…kitty integration…" bold italic yellow)
} 

#==================================================== - GENERAL ENVIRONMENT
set-env PAPERSIZE A4
if (not (has-env PLATFORM)) { set-env PLATFORM (str:to-lower (uname -s)) }
if (is-macos) {
	do-if-path /Applications/MATLAB/MATLAB_Runtime/v912/ {|p| set-env MRT $p }
	do-if-path [/usr/local/Cellar/openjdk/19] {|p| set-env JAVA_HOME (/usr/libexec/java_home -v 19) }
}

if-external nvim { set-env EDITOR 'nvim'; set-env VISUAL 'nvim' } { set-env EDITOR 'vim'; set-env VISUAL 'vim' }
# brew tap rsteube/homebrew-tap; brew install rsteube/tap/carapace
if-external carapace { eval (carapace _carapace elvish | slurp); echo (styled "…carapace init…" bold italic yellow) }
if-external procs { eval (procs --gen-completion-out elvish | slurp ) }
if-external rbenv { set-env RBENV_SHELL elvish; set-env RBENV_ROOT $E:HOME'/.rbenv' }
if-external pyenv { set-env PYENV_SHELL elvish; set-env PYENV_ROOT $E:HOME'/.pyenv' }
python:deactivate

#==================================================== - MAIN ALIASES
if (not-file $E:XDG_CONFIG_HOME/elvish/lib/aliases.elv) {
	mkdir -p $E:XDG_CONFIG_HOME/elvish/lib/
	ln -s $E:HOME/.dotfiles/aliases.elv $E:XDG_CONFIG_HOME/elvish/lib/aliases.elv
}
use aliases

#==================================================== - THEME
if-external starship { 
	echo (styled "…starship init…" bold italic yellow)
	eval ((search-external starship) init elvish --print-full-init | slurp)
	eval ((search-external starship) completions elvish | slurp)
} { use github.com/muesli/elvish-libs/theme/powerline } 

#==================================================== - SHIM FOLDERS
put $E:HOME{/scoop/shims /.pyenv/shims /.rbenv/shims} | each {|p| prepend-to-path $p} # needs to go after brew init

#==================================================== - THIS IS THE END, MY FRIEND
fn helpme { echo (styled "\n ! – last cmd ░ ⌃N – 🚀navigate ░ ⌃R – 🔍history ░ ⌃L – 🔍dirs\n ⌃B – 🖊️cmd ░ ⌃a,e – ⇄ ░ ⌃u – ⌫line ░ 💡 curl cheat.sh/?\n tmux prefix §=^a — tmux-pane: split=§| §- close=§x focus=§o\n tmux window create=§c switch=§n close=§&\n" bold italic fg-yellow ) }
helpme
echo (styled "◖ Elvish V"$version"—"$platform:os"▷"$platform:arch" ◗" bold italic yellow)

