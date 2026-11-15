#====================================================
#  __|  |      _)       |   
#  _|   | \ \ / | (_-<    \ 
# ___| _|  \_/ _| ___/ _| _|
# elvish shell config: https://elv.sh/learn/tour.html
#====================================================

#==================================================== - CORE MODULES
use re
use str
use epm
use path
use math
use platform
use doc
use md
use os
use runtime
if $platform:is-unix { use unix; edit:add-var unix: $unix: }
echo (styled "𓁜◖" bold "#FFAA33")(styled "Elvish V"$version"—"$platform:os"▷"$platform:arch bold italic bg-"#FFAA33" black)(styled "◗𓁝" bold "#FFAA33")
fn msg { |@t| echo (styled "👉🏼 "$@t bold italic yellow) }

# Cache generated integration code (completions, prompts). The generators are
# external programs whose output only changes when the tool changes, so replay
# the cached code until the binary's mtime is newer than the cache file.
# `stat` is used because os:stat does not expose mtime; on macOS it is BSD
# stat, on Linux GNU stat. Clear with: rm -rf ~/.cache/elvish/completions
fn stat-mtime {|f|
	if (eq $platform:os windows) { put 0; return }
	var out = ''
	if (eq $platform:os darwin) { set out = (stat -L -f %m $f) } else { set out = (stat -L -c %Y $f) }
	put (num (str:trim-space $out))
}
fn cached-code {|name bin @cmd|
	var bp = ''
	try { set bp = (search-external $bin) } catch { put ''; return }
	var base = $E:XDG_CACHE_HOME
	if (==s $base '') { set base = $E:HOME'/.cache' }
	var dir = $base'/elvish/completions'
	var file = $dir'/'$name'.elv'
	var stale = $true
	if (path:is-regular $file) {
		set stale = $false
		try {
			if (> (stat-mtime $bp) (stat-mtime $file)) { set stale = $true }
		} catch { set stale = $true }
	}
	if $stale {
		var code = ($bp $@cmd | slurp)
		if (==s $code '') { put ''; return }
		os:mkdir-all $dir
		print $code > $file
	}
	put (slurp < $file)
}

#==================================================== - EXTERNAL MODULES
try { epm:install &silent-if-installed ^
	github.com/iandol/elvish-modules ^
	github.com/zzamboni/elvish-modules ^
	github.com/muesli/elvish-libs } catch { msg "…can't install elvish modules…" }

use github.com/iandol/elvish-modules/cmds # my utility module
use github.com/iandol/elvish-modules/python # for python venv support
use github.com/iandol/elvish-modules/mamba # for conda support
use github.com/zzamboni/elvish-modules/bang-bang # use ! for last command expansion
bang-bang:init &plain-bang="Alt-1" # remember for kitty this is RIGHT alt key only

#==================================================== - BASIC ENVIRONMENT
if $platform:is-windows { set-env HOME $E:USERPROFILE; set-env USER $E:USERNAME }
set-env HOSTNAME (platform:hostname &strip-domain=$true)
set-env DF $E:HOME/.dotfiles
set-env XDG_CONFIG_HOME $E:HOME/.config
set-env XDG_DATA_HOME $E:HOME/.local/share
if (==s $platform:os "linux") { set-env TMPDIR '/tmp' }
# One pair of uname calls for the whole startup (banner, PROCESSOR, PLATFORM).
var machine = ''
var sysname = ''
try { set machine = (uname -m); set sysname = (uname -s) } catch { }

#==================================================== - IMPORT UTIL NAMES TO REPL
peach {|c| # this adds function names from cmds module to REPL, from Kurtis
	var code = 'edit:add-var '$c' $mod:'$c; eval $code &ns=(ns [&mod:=$cmds:])
	} [if-external~ append-to-path~ prepend-to-path~ do-if-path~
	is-path~ is-file~ not-path~ not-file~ is-macos~ is-linux~ 
	is-arm64~ is-macintel~ is-macarm~]
edit:add-vars [
	&mama~=$mamba:activate~
	&mamd~=$mamba:deactivate~
	&maml~=$mamba:list~
	&pya~=$python:activate~
	&pyc~={ |@in| python -m venv $python:venv-directory"/"$@in }
	&pyd~=$python:deactivate~
	&pyl~=$python:list-venvs~]
set edit:completion:arg-completer[pya] = $edit:completion:arg-completer[python:activate]
set edit:completion:arg-completer[mama] = $edit:completion:arg-completer[mamba:activate]

#==================================================== - PATHS + VENVS
try { cmds:path_helper } catch { } # /usr/libexec/path_helper for elvish

# MATLAB -- https://www.mathworks.com/help/matlab/matlab-environment.html
var prefix suffix
if (cmds:is-macos) { set prefix = "/Applications/MATLAB_R202"; set suffix = ".app/bin"
} else { set prefix = "/usr/local/MATLAB/R202"; set suffix = "/bin" }
var releases = [$prefix{6b 6a 5b 5a 4b 4a 3b 3a 2b 2a 1b 1a 0b 0a}$suffix]
cmds:do-if-path $releases { |p|
	cmds:prepend-to-path $p
	set-env MATLAB_EXECUTABLE $p"/matlab" # matlab
	if (cmds:is-macos) { ln -sf $p"/maci64/mlint" $E:HOME/bin/mlint }
}
if (cmds:is-macos) {
	cmds:do-if-path [(/usr/libexec/java_home -v {25 21 17 11 8})] {|p| set-env JAVA_HOME $p }
	cmds:do-if-path	[(/usr/libexec/java_home -v {21 17 11 8})] {|p| set-env MATLAB_JAVA $p }
} elif (cmds:is-linux) {
	var jj = [/usr/lib/jvm/temurin-{21 17 11 8}-jdk-amd64 
		/usr/lib/jvm/java-{21 17 11 8}-openjdk-amd64 
		$E:HOME'/.pixi/envs/openjdk/lib/jvm/']
	cmds:do-if-path $jj { |p| set-env JAVA_HOME $p; set-env MATLAB_JAVA $p }
	# This breaks MESA drivers
	# cmds:do-if-path [/usr/local/MATLAB/MATLAB_Runtime/R202{5b 5a 4b 4a 3b 3a}/] { |p| set-env LD_LIBRARY_PATH $p'runtime/glnxa64:'$p'bin/glnxa64:'$p'sys/os/glnxa64:'$p'extern/bin/glnxa64:'$p'sys/opengl/lib/glnxa64:'$E:LD_LIBRARY_PATH }
}

# prepend / append paths only if they exist and not already in path
each {|p| cmds:prepend-to-path $p } [ /Library/TeX/texbin  ~/Library/TinyTeX/bin/universal-darwin  ~/.TinyTeX/bin/x86_64-linux
	~/scoop/apps/msys2/current/usr/bin  ~/.rbenv/shims  ~/.pyenv/shims  ~/scoop/shims
	/opt/amdgpu-pro/bin  /opt/amdgpu/bin  
	~/.cache/lm-studio/bin ~/.antigravity/antigravity/bin ~/.opencode/bin
	/Applications/mpv.app/Contents/MacOS
	/usr/local/bin  /usr/local/sbin  ~/.local/bin
	/home/linuxbrew/.linuxbrew/bin  /opt/local/bin  /opt/homebrew/bin
	/usr/local/opt/ruby/bin  /usr/local/lib/ruby/gems/3.{7 6 5 4 3}.0/bin  /opt/homebrew/opt/ruby/bin /opt/homebrew/lib/ruby/gems/3.{7 6 5 4 3}.0/bin
	~/.pixi/envs/ruby/share/rubygems/bin ~/.pixi/envs/nodejs/bin ~/.x-cmd.root/bin  ~/.pixi/bin $E:HOME/bin]
each {|p| cmds:append-to-path $p } [ /opt/homebrew/opt/python@3.{15 14 13 12 11 10}/libexec/bin
	/Library/Frameworks/GStreamer.framework/Commands]

cmds:do-if-path $E:HOME/.pixi/envs/ruby/share/rubygems {|p| set-env GEM_HOME $p }
cmds:do-if-path $E:HOME/.venv {|p| set python:venv-directory = $p }
cmds:do-if-path [/media/cogp/micromamba /media/cog/data/micromamba $E:HOME/micromamba ] {|p| set mamba:root = $p; set-env MAMBA_ROOT_PREFIX $mamba:root }

#==================================================== - HOMEBREW
if (cmds:is-macintel) { cmds:prepend-to-path '/usr/local/bin' } # intel homebrew (native or via Rosetta 2)
cmds:if-external brew {
	var pfix = ''
	if (has-env HOMEBREW_PREFIX) { set pfix = $E:HOMEBREW_PREFIX }
	if (==s $pfix '') {
		if (cmds:is-macarm) { set pfix = '/opt/homebrew' }
		elif (cmds:is-macintel) { set pfix = '/usr/local' }
		else { set pfix = (brew --prefix) }
	}
	echo (styled "👉🏼 …configuring homebrew "$platform:os"-"$platform:arch" [runmode:"$machine"] prefix: "$pfix" …" bold italic yellow)
	set-env HOMEBREW_PREFIX $pfix
	set-env HOMEBREW_CELLAR $pfix'/Cellar'
	set-env HOMEBREW_REPOSITORY $pfix'/Homebrew'
	set-env HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS 1
	if (cmds:is-macos) { set-env DYLD_FALLBACK_LIBRARY_PATH /opt/homebrew/lib }
	set-env MANPATH $pfix'/share/man:'$E:MANPATH
	set-env INFOPATH $pfix'/share/info:'$E:INFOPATH
	peach {|p| cmds:prepend-to-path $p } [ $pfix'/bin' $pfix'/sbin']
}

#==================================================== - KITTY INTEGRATION
if (has-env KITTY_INSTALLATION_DIR) {
	fn osc {|c| print "\e]"$c"\a" }
	fn send-title {|t| osc '0;ɛ'$t }
	fn send-pwd { send-title (tilde-abbr $pwd | path:base (one)); osc '7;'(put $pwd)}
	set edit:before-readline = [ { send-pwd } { osc '133;A' } ]
	set edit:after-readline = [ {|c| send-title (str:split ' ' $c | take 1) } {|c| osc '133;C' } ]
	set after-chdir = [ {|_| send-pwd } ]
	msg "…"(kitty --version)" integration…"
}

#==================================================== - GHOSTTY INTEGRATION
if (eq $E:TERM "xterm-ghostty") {
	use ghostty-integration
	msg "…ghostty integration…"
}

#==================================================== - OTHER INTEGRATIONS
cmds:if-external zoxide { eval (zoxide init elvish | slurp) } # better cd
cmds:if-external fd {
	cmds:if-external fzf {
		set-env FZF_DEFAULT_COMMAND "fd --type file --color=always --follow --hidden --exclude .git"
		set-env FZF_DEFAULT_OPTS "--ansi"
	}
}
cmds:if-external nvim {
	var nvimPath = (which nvim)
	set-env EDITOR $nvimPath
	set-env VISUAL $nvimPath
} { set-env EDITOR 'vim'; set-env VISUAL 'vim' }
cmds:if-external herdr { eval (cached-code herdr herdr completion elvish) } # tmux alternative
cmds:if-external uv { eval (cached-code uv uv generate-shell-completion elvish) } # python manager
cmds:if-external rotz { eval (cached-code rotz rotz completions elvish) } # dotfile namager
cmds:if-external dua { eval (cached-code dua dua completions elvish) } # disk usage analyzer
#cmds:if-external procs { eval (procs --gen-completion-out elvish | slurp ) } # process viewer #in carapace
cmds:if-external mihomosh { eval (cached-code mihomosh mihomosh shell-completion elvish) } # mihomo shell
cmds:if-external pixi {
	# Do NOT call `pixi info` during startup: it resolves the channel's virtual
	# package detectors and can retry conda.anaconda.org requests (3 attempts)
	# on every shell start. The global layout is deterministic:
	#   $PIXI_HOME/bin (default ~/.pixi/bin) and $PIXI_HOME/envs.
	var pixiHome = $E:PIXI_HOME
	if (==s $pixiHome '') { set pixiHome = $E:HOME'/.pixi' }
	var pixienv = $pixiHome'/envs'
	var pixibin = $pixiHome'/bin'
	# pixi doesn't expose tools installed with gem etc. so manually expose them
	if (cmds:not-file $pixibin/pandocomatic) { ln -sf $pixienv/ruby/share/rubygems/bin/pandocomatic $pixibin }
} # global package manager
python:deactivate


#==================================================== - GENERAL ENVIRONMENT
set-env PAPERSIZE A4
set-env PROCESSOR (str:to-lower $machine)
if (not (has-env PLATFORM)) { set-env PLATFORM (str:to-lower $sysname) }

#==================================================== - LUA PATHS
if (not (has-env LUA_PATH)) { set-env LUA_PATH ';'; set-env LUA_CPATH ';' }
cmds:do-if-path ~/.local/share/pandoc/filters {|p| set-env LUA_PATH $p'/?.lua;'$E:LUA_PATH }
cmds:do-if-path /opt/homebrew/share/lua/5.4 {|p| set-env LUA_PATH $p'/?.lua;'$p'/?/?.lua;'$E:LUA_PATH}
cmds:do-if-path /opt/homebrew/lib/lua/5.4 {|p| set-env LUA_CPATH $p'/?.so;'$p'/?/?.so;'$E:LUA_CPATH}
cmds:do-if-path /home/linuxbrew/.linuxbrew/share/lua/5.4 {|p| set-env LUA_PATH $p'/?.lua;'$p'/?/?.lua;'$E:LUA_PATH}
cmds:do-if-path /home/linuxbrew/.linuxbrew/lib/lua/5.4 {|p| set-env LUA_CPATH $p'/?.so;'$p'/?/?.so;'$E:LUA_CPATH}
cmds:do-if-path ~/.pixi/envs/luarocks/share/lua/5.4 {|p| set-env LUA_PATH $p'/?.lua;'$p'/?/?.lua;'$E:LUA_PATH}
cmds:do-if-path ~/.pixi/envs/luarocks/lib/lua/5.4 {|p| set-env LUA_CPATH $p'/?.so;'$p'/?/?.so;'$E:LUA_CPATH}
cmds:do-if-path ~/.local/share/pandoc/ {|p| set-env PD $p }

#==================================================== - CARAPACE INTEGRATION
cmds:if-external carapace {
	msg "…carapace integration…"
	set-env CARAPACE_BRIDGES "bash,zsh"
	set-env CARAPACE_EXCLUDES "systemctl,x"
	set-env CARAPACE_MERGEFLAGS 1
	eval (cached-code carapace carapace _carapace elvish)
	#carapace --choice ansible/zsh@bridge
} 

#==================================================== - X-CMD 文
# …should come AFTER carapace
if (os:is-regular (path:dir $runtime:rc-path)/lib/x.elv) {
	set-env ___X_CMD_LANG en
	set-env ___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL 0
	use x; x:init
	msg "…x-cmd 文 integration…"
}

#==================================================== - MY ALIASES
use aliases 

#==================================================== - KEY BINDINGS
set edit:insert:binding[Ctrl-a] = $edit:move-dot-sol~
set edit:insert:binding[Ctrl-e] = $edit:move-dot-eol~
set edit:insert:binding[Ctrl-b] = { aliases:external-edit-command }
set edit:insert:binding[Ctrl-y] = { echo $edit:current-command | pbcopy; edit:replace-input ""; edit:notify "Cut ✂️" }
cmds:if-external fzf { set edit:insert:binding[Ctrl-r] = { aliases:history >/dev/tty 2>&1 } }

#==================================================== - THEME
cmds:if-external starship {
	eval (cached-code starship starship init elvish --print-full-init)
	#eval ((search-external starship) completions elvish | slurp)
	msg "…starship init…"
} { use github.com/muesli/elvish-libs/theme/powerline }

#==================================================== - ENSURE SHIM DIRS PREPENDED
each {|p| cmds:prepend-to-path $p} [$E:HOME{/scoop/shims /.pyenv/shims /.rbenv/shims /.pixi/bin /bin}]

#==================================================== 
#========================- THIS IS THE END, MY FRIEND
#==================================================== 
