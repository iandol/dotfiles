#==================================================== - ELVISH CONFIG
# elvish shell config: https://elv.sh/learn/tour.html
# see a sample here: https://gitlab.com/zzamboni/dot-elvish/-/blob/master/rc.org
#===============================================

#==================================================== - INTERNAL MODULES
use re
use str
use path
use math
use epm
use platform
if (not (path:is-regular &follow-symlink ~/.config/elvish/lib/cmds.elv)) {
	mkdir -p ~/.config/elvish/lib/
	ln -s ~/.dotfiles/cmds.elv ~/.config/elvish/lib/
}
use cmds
#use readline-binding
if $platform:is-unix { use unix; edit:add-var unix: $unix: }
try { use doc } catch { }

echo (styled "◖ Elvish V"$version"—"$platform:os"▷"$platform:arch" ◗" bold italic white)

#==================================================== - EXTERNAL MODULES
epm:install &silent-if-installed ^
	github.com/iwoloschin/elvish-packages ^
	github.com/zzamboni/elvish-modules ^
	github.com/zzamboni/elvish-themes ^
	github.com/zzamboni/elvish-completions ^
	github.com/xiaq/edit.elv 

use github.com/zzamboni/elvish-modules/proxy
use github.com/zzamboni/elvish-modules/bang-bang
use github.com/zzamboni/elvish-modules/spinners
use github.com/href/elvish-gitstatus/gitstatus
use github.com/iwoloschin/elvish-packages/python
#use github.com/zzamboni/elvish-completions/git
#use github.com/zzamboni/elvish-completions/cd
#use github.com/zzamboni/elvish-completions/ssh

#==================================================== - IMPORT UTIL NAMES
var if-external~		= $cmds:if-external~
var append-to-path~		= $cmds:append-to-path~
var prepend-to-path~	= $cmds:prepend-to-path~
var is-path~			= $cmds:is-path~
var is-file~			= $cmds:is-file~
var is-macos~			= $cmds:is-macos~
var is-linux~			= $cmds:is-linux~
var is-arm64~			= $cmds:is-arm64~
var pya~				= $python:activate~
var pyd~				= $python:deactivate~
var pyl~				= $python:list-virtualenvs~
set edit:completion:arg-completer[pya] = $edit:completion:arg-completer[python:activate]

#==================================================== - PATHS
set paths = [
	~/bin
	/usr/local/bin
	/usr/local/sbin
	$@paths
]
var ppaths = [
	/Library/TeX/texbin
	/opt/local/bin
	/usr/local/opt/python@3.10/libexec/bin
	~/.rbenv/shims
	~/.pyenv/shims
	/opt/homebrew/bin
	/home/linuxbrew/.linuxbrew/bin
]
var apaths = [
	/Library/Frameworks/GStreamer.framework/Commands
]
each {|p| if (is-path $p) { prepend-to-path $p }} $ppaths
each {|p| if (is-path $p) { append-to-path $p }} $apaths

var releases = [R2023b R2023a R2022b R2022a R2021b R2021a R2020b R2020a]
var match = $false; var prefix; var suffix
if (is-macos) {
	set prefix = "/Applications/MATLAB_"; set suffix = ".app/bin"
} else {
	set prefix = "/usr/local/MATLAB/"; set suffix = "/bin"
}
each {|p|
	if (and (eq $match $false) (is-path $prefix$p$suffix)) {
		set match = $true
		prepend-to-path $prefix$p$suffix
		set-env MATLAB_EXECUTABLE $prefix$p$suffix"/matlab" # matlab
		if (is-macos) { ln -sf $prefix$p$suffix"/maci64/mlint" ~/bin/mlint }
	}
} $releases
if (is-path ~/.venv/) { set python:virtualenv-directory = $E:HOME'/.venv' }

#==================================================== - SETUP BREW
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
set-env XDG_CONFIG_HOME $E:HOME"/.config"
set-env XDG_DATA_HOME $E:HOME"/.local/share"
set-env DF $E:HOME"/.dotfiles"
if (not (has-env PLATFORM)) { set-env PLATFORM (str:to-lower (uname -s)) }
if (is-macos) {
	if (is-path /Applications/MATLAB/MATLAB_Runtime/v912/) { set-env MRT /Applications/MATLAB/MATLAB_Runtime/v912/ }
	if (is-path /usr/local/Cellar/openjdk/19) { set-env JAVA_HOME (/usr/libexec/java_home -v 19) }
}
if-external vim { set-env EDITOR 'vim'; set-env VISUAL 'vim' }
if-external nvim { set-env EDITOR 'nvim'; set-env VISUAL 'nvim' }
# brew tap rsteube/homebrew-tap; brew install rsteube/tap/carapace
if-external carapace { eval (carapace _carapace elvish | slurp); echo (styled "…carapace init…" bold italic yellow) }
if-external procs { eval (procs --completion-out elvish | slurp ) }
if-external rbenv { set-env RBENV_SHELL elvish; set-env RBENV_ROOT $E:HOME'/.rbenv' }
if-external pyenv { set-env PYENV_SHELL elvish; set-env PYENV_ROOT $E:HOME'/.pyenv' }
python:deactivate

#==================================================== - ALIASES
if (not (is-file ~/.config/elvish/lib/aliases.elv)) {
	mkdir -p ~/.config/elvish/lib/
	ln -s ~/.dotfiles/aliases.elv ~/.config/elvish/lib/
}
use aliases

#==================================================== - THEME
var theme = chain
if-external starship { set theme = starship }
if (eq $theme starship) {
	echo (styled "…carapace init…" bold italic yellow)
	eval ((which starship) init elvish)
	eval ((which starship) completions elvish | slurp)
} elif (eq $theme powerline) {
	use github.com/muesli/elvish-libs/theme/powerline
} else {
	use github.com/zzamboni/elvish-themes/chain
	chain:init
	set chain:bold-prompt = $true
	set chain:show-last-chain = $false
	set chain:glyph[arrow] = "⇝"
	set chain:prompt-segment-delimiters = [ "⎛" "⎞" ]
}

#==================================================== - SHIM FOLDERS
put $E:HOME{/.pyenv/shims /.rbenv/shims} | each {|p| prepend-to-path $p} # needs to go after brew init

#==================================================== - END
fn helpme { echo (styled "\n ! – last cmd ░ ⌃N – 🚀navigate ░ ⌃R – 🔍history ░ ⌃L – 🔍dirs\n ⌃B – 🖊️cmd ░ ⌃a,e – ⇄ ░ ⌃u – ⌫line ░ 💡 curl cheat.sh/?\n tmux prefix §=^a — tmux-pane: split=§| §- close=§x focus=§o\n tmux window create=§c switch=§n close=§&\n" bold italic fg-yellow ) }
helpme
