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
use md
use os
if $platform:is-unix { use unix; edit:add-var unix: $unix: } 

#==================================================== - EXTERNAL MODULES
try { epm:install &silent-if-installed ^
	github.com/iandol/elvish-modules ^
	github.com/zzamboni/elvish-modules ^
	github.com/muesli/elvish-libs } catch { echo "Cannot install external modules..." }

use github.com/iandol/elvish-modules/cmds # my utility module
use github.com/iandol/elvish-modules/ai # my ai module
use github.com/iandol/elvish-modules/python # for python venv support
use github.com/iandol/elvish-modules/mamba # for conda/mamba support
use github.com/zzamboni/elvish-modules/bang-bang
use github.com/zzamboni/elvish-modules/spinners

#==================================================== - BASIC ENVIRONMENT
set-env XDG_CONFIG_HOME $E:HOME/.config
set-env XDG_DATA_HOME $E:HOME/.local/share
if $platform:is-windows { set-env HOME $E:USERPROFILE; set-env USER $E:USERNAME }
if (==s $platform:os "linux") { set-env TMPDIR '/tmp' }

#==================================================== - IMPORT UTIL NAMES TO REPL
each {|c| # this adds function names from cmds module to REPL, from Kurtis
	var code = 'edit:add-var '$c' $mod:'$c
	eval $code &ns=(ns [&mod:=$cmds:])
} [if-external~ append-to-path~ prepend-to-path~ do-if-path~
	is-path~ is-file~ not-path~ not-file~ is-macos~ is-linux~ 
	is-arm64~ is-macintel~ is-macarm~]
edit:add-var mama~	$mamba:activate~
edit:add-var mamd~	$mamba:deactivate~
edit:add-var maml~	$mamba:list~
edit:add-var pya~	$python:activate~
edit:add-var pyc~	{ |@in| python -m venv $python:venv-directory"/"$@in }
edit:add-var pyd~	$python:deactivate~
edit:add-var pyl~	$python:list-venvs~
set edit:completion:arg-completer[pya] = $edit:completion:arg-completer[python:activate]
set edit:completion:arg-completer[mama] = $edit:completion:arg-completer[mamba:activate]

#==================================================== - PATHS + VENVS
var prefix; var suffix
if (cmds:is-macos) {
	set prefix = "/Applications/MATLAB_"; set suffix = ".app/bin"
} else {
	set prefix = "/usr/local/MATLAB/"; set suffix = "/bin"
}
var releases = [$prefix{R2024b R2024a R2023b R2023a R2022b R2022a R2021b R2021a R2020b R2020a}$suffix]
cmds:do-if-path $releases {|p|
	cmds:prepend-to-path $p
	set-env MATLAB_EXECUTABLE $p"/matlab" # matlab
	if (cmds:is-macos) { ln -sf $p"/maci64/mlint" $E:HOME/bin/mlint }
}
each {|p| cmds:prepend-to-path $p } [
	/Library/TeX/texbin  ~/Library/TinyTeX/bin/universal-darwin ~/.TinyTeX/bin/x86_64-linux 
	~/scoop/apps/msys2/current/usr/bin
	~/.rbenv/shims  ~/.pyenv/shims ~/scoop/shims
	~/bin  ~/.cache/lm-studio/bin
	/usr/local/bin  /usr/local/sbin
	/home/linuxbrew/.linuxbrew/bin
	/opt/local/bin  /opt/homebrew/bin
]
each {|p| cmds:append-to-path $p } [
	/usr/local/opt/python@{3.14 3.13 3.12 3.11 3.10 3.9}/libexec/bin
	/Library/Frameworks/GStreamer.framework/Commands
]

cmds:do-if-path $E:HOME/.venv {|p| set python:venv-directory = $p }
cmds:do-if-path [/media/cogp/micromamba /media/cog/data/micromamba $E:HOME/micromamba ] {|p| set mamba:root = $p; set-env MAMBA_ROOT_PREFIX $mamba:root }

#==================================================== - SETUP HOMEBREW
if (cmds:is-macintel) { cmds:prepend-to-path '/usr/local/bin' } # intel homebrew (native or via Rosetta 2)
cmds:if-external brew {
	var pfix = (brew --prefix)
	if (cmds:is-macintel) { var pfix = '/usr/local' }
	echo (styled "…configuring homebrew "$platform:os"-"$platform:arch" [runmode:"(uname -m)"] prefix: "$pfix" …" bold italic yellow)
	set-env HOMEBREW_PREFIX $pfix
	set-env HOMEBREW_CELLAR $pfix'/Cellar'
	set-env HOMEBREW_REPOSITORY $pfix'/Homebrew'
	set-env MANPATH $pfix'/share/man:'$E:MANPATH
	set-env INFOPATH $pfix'/share/info:'$E:INFOPATH
	each {|p| cmds:prepend-to-path $p } [ $pfix'/bin' $pfix'/sbin']
}

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
set-env PROCESSOR (str:to-lower (uname -m))
if (not (has-env PLATFORM)) { set-env PLATFORM (str:to-lower (uname -s)) }
if (cmds:is-macos) {
	cmds:do-if-path /Applications/MATLAB/MATLAB_Runtime/v912/ {|p| set-env MRT $p }
	cmds:do-if-path [/usr/local/Cellar/openjdk/19] {|p| set-env JAVA_HOME (/usr/libexec/java_home -v 19) }
}

if (not (has-env LUA_PATH)) { set-env LUA_PATH ';'; set-env LUA_CPATH ';' }
cmds:do-if-path $E:HOME/.local/share/pandoc/filters {|p| set-env LUA_PATH $p'/?.lua;'$E:LUA_PATH }
cmds:do-if-path /opt/homebrew/share/lua/5.4 {|p| set-env LUA_PATH $p'/?.lua;'$p'/?/?.lua;'$E:LUA_PATH}
cmds:do-if-path /opt/homebrew/lib/lua/5.4 {|p| set-env LUA_CPATH $p'/?.so;'$p'/?/?.so;'$E:LUA_CPATH}

# brew tap rsteube/homebrew-tap; brew install rsteube/tap/carapace
cmds:if-external carapace { set-env CARAPACE_BRIDGES 'zsh,bash'; eval (carapace _carapace|slurp); echo (styled "…carapace init…" bold italic yellow) }
cmds:if-external nnn { set-env NNN_FIFO /tmp/nnn.fifo; set-env NNN_TERMINAL (which kitty); set-env NNN_PLUG 'f:finder;o:fzopen;p:preview-tui' }
cmds:if-external procs { eval (procs --gen-completion-out elvish | slurp ) }
cmds:if-external rbenv { set-env RBENV_SHELL elvish; set-env RBENV_ROOT $E:HOME'/.rbenv' }
cmds:if-external pyenv { set-env PYENV_SHELL elvish; set-env PYENV_ROOT $E:HOME'/.pyenv' }
cmds:if-external nvim { set-env EDITOR 'nvim'; set-env VISUAL 'nvim' } { set-env EDITOR 'vim'; set-env VISUAL 'vim' }
python:deactivate

#==================================================== - MAIN ALIASES
if (cmds:not-file $E:HOME/.config/elvish/lib/aliases.elv) {
	mkdir -p $E:HOME/.config/elvish/lib/
	ln -s $E:HOME/.dotfiles/aliases.elv $E:HOME/.config/elvish/lib/aliases.elv
}
use aliases

#==================================================== - KEY BINDINGS
set edit:insert:binding[Ctrl-a] = $edit:move-dot-sol~
set edit:insert:binding[Ctrl-e] = $edit:move-dot-eol~
set edit:insert:binding[Ctrl-b] = { aliases:external-edit-command }
cmds:if-external fzf { set edit:insert:binding[Ctrl-R] = { aliases:history >/dev/tty 2>&1 } }
#set edit:insert:binding[Ctrl-l] = { $edit:move-dot-eol~; $edit:kill-line-left~ }

#==================================================== - THEME
cmds:if-external starship { 
	echo (styled "…starship init…" bold italic yellow)
	eval ((search-external starship) init elvish --print-full-init | slurp)
	eval ((search-external starship) completions elvish | slurp)
} { use github.com/muesli/elvish-libs/theme/powerline } 

#==================================================== - SHIM FOLDERS
put $E:HOME{/scoop/shims /.pyenv/shims /.rbenv/shims} | each {|p| cmds:prepend-to-path $p} # needs to go after brew init

#==================================================== - THIS IS THE END, MY FRIEND
fn helpme { echo (styled "
! – last cmd 🔹 ⌃N – 🚀navigate 🔹 ⌃R – 🔍history 🔹 ⌃L – 🔍dirs
⌃B – 🖊️cmd 🔹 ⌃a,e – ⇄ 🔹 ⌃u – ⌫line 🔹 💡 curl cheat.sh/?
VIM :e load-buf 🔹 :bn next-buf 🔹 :ls list-buf 🔹 :bd close-buf
  :tab ba buf>tabs 🔹 gt next-tab 🔹 :vert ba vertical
  ^w[s|v] split-viewport 🔹 ^ww switch-vp 🔹 ^wx exchange-vp
  [N]yy=yank 🔹 [N]dd=cut 🔹 p=paste 🔹 *# jump to word
  / pattern-search 🔹 n=next
TMUX prefix §=^a 🔹 tmux-pane: split=§| §- close=§x focus=§o
  sessions=§s detach=§d window-create=§c switch=§n close=§&
  commands=§: help=§? navigate=§w" bold italic fg-yellow ) }
helpme
echo (styled "◖ Elvish V"$version"—"$platform:os"▷"$platform:arch" ◗" bold italic yellow)

