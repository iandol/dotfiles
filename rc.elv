# elvish shell config: https://elv.sh/learn/tour.html
# see a sample here: https://gitlab.com/zzamboni/dot-elvish/-/blob/master/rc.org

################################################ https://elv.sh/ref/
use re
use str
use path
use math
use epm
use platform
#use readline-binding
if (not (path:is-regular &follow-symlink=$true ~/.config/elvish/lib/cmds.elv)) {
	mkdir -p ~/.config/elvish/lib/
	ln -s ~/.dotfiles/cmds.elv ~/.config/elvish/lib/
}
use cmds

################################################ Export Utils
var only-when-external~ = $cmds:only-when-external~
var append-to-path~ = $cmds:append-to-path~
var prepend-to-path~ = $cmds:prepend-to-path~

################################################ Key bindings
set edit:insert:binding[Ctrl-a] = $edit:move-dot-sol~
set edit:insert:binding[Ctrl-e] = $edit:move-dot-eol~

################################################ Paths
set paths = [
	~/bin
	/usr/local/bin
	/usr/local/sbin
	$@paths
	/usr/sbin
	/sbin
	/usr/bin
	/bin
]
if (path:is-dir &follow-symlink /Library/TeX/texbin) { prepend-to-path /Library/TeX/texbin }
if (path:is-dir /opt/local/bin ) { prepend-to-path /opt/local/bin }
if (path:is-dir /Library/Frameworks/GStreamer.framework/Commands ) { append-to-path /Library/Frameworks/GStreamer.framework/Commands }
only-when-external rbenv { prepend-to-path ~/.rbenv/shims/ }
each {|p|
	if (not (path:is-dir &follow-symlink $p)) {
		echo (styled "🥺—"$p" in $paths no longer exists…" bg-red)
	}
} $paths

var release = ["R2022a" "R2021b" "R2021a" "R2020b" "R2020a"]
var match = $false; var prefix; var suffix
if (eq $platform:os 'darwin') {
	set prefix = "/Applications/MATLAB_"; set suffix = ".app/bin"
} else {
	set prefix = "/usr/local/MATLAB/"; set suffix = "/bin"
}
each {|p|
	if (and (eq $match $false) (path:is-dir &follow-symlink $prefix$p$suffix)) {
		set match = $true
		set paths = [$prefix$p$suffix $@paths] # matlab
		set-env MATLAB_EXECUTABLE $prefix$p$suffix"/matlab" # matlab
		ln -sf $prefix$p$suffix"/maci64/mlint" ~/bin/mlint # matlab
	}
} $release

################################################ External modules
epm:install &silent-if-installed ^
	github.com/xiaq/edit.elv ^
	github.com/zzamboni/elvish-modules ^
	github.com/zzamboni/elvish-themes ^
	github.com/zzamboni/elvish-completions ^
	#github.com/muesli/elvish-libs ^

#use github.com/muesli/elvish-libs/theme/powerline
use github.com/zzamboni/elvish-modules/proxy
use github.com/zzamboni/elvish-modules/bang-bang
use github.com/zzamboni/elvish-modules/spinners
use github.com/zzamboni/elvish-completions/git
use github.com/zzamboni/elvish-completions/cd
use github.com/zzamboni/elvish-completions/ssh
use github.com/href/elvish-gitstatus/gitstatus

# chain theme
use github.com/zzamboni/elvish-themes/chain
chain:init
set chain:bold-prompt = $true
set chain:show-last-chain = $false
set chain:glyph[arrow] = "⇝"
set chain:prompt-segment-delimiters = [ "⎛" "⎞" ]

################################################ general ENV
if ( has-env PLATFORM ) {
	echo (styled "Elvish V"$version" running on "$E:PLATFORM bold italic white bg-blue)
} else {
	set-env PLATFORM (str:to-lower (uname -s))
	echo (styled "Elvish V"$version" running on "$E:PLATFORM bold italic white bg-blue)
}
if ( path:is-dir /Applications/ZeroBraneStudio.app ) { 
	var ZBS = '/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio'
	set-env ZBS $ZBS
	set-env LUA_PATH "./?.lua;"$ZBS"/lualibs/?/?.lua;"$ZBS"/lualibs/?.lua"  
	set-env LUA_CPATH $ZBS"/bin/?.dylib;"$ZBS"/bin/clibs53/?.dylib;"$ZBS"/bin/clibs53/?/?.dylib"	
}

################################################ aliases
if (not (path:is-regular &follow-symlink=$true ~/.config/elvish/lib/aliases.elv)) {
	mkdir -p ~/.config/elvish/lib/
	ln -s ~/.dotfiles/aliases.elv ~/.config/elvish/lib/
}
use aliases

################################################ setup brew
if ( and (eq $platform:os 'linux') (path:is-dir &follow-symlink /home/linuxbrew/.linuxbrew/bin/) ) {
	echo (styled "…configuring "$platform:os" brew…\n" bold italic bg-blue)
	set paths = [/home/linuxbrew/.linuxbrew/bin/ /home/linuxbrew/.linuxbrew/sbin/ $@paths]
} elif ( and (eq $platform:os 'darwin') (path:is-dir &follow-symlink /usr/local/Homebrew/bin) ) {
	echo (styled "…configuring "$platform:os" brew…\n" bold italic white bg-blue)
	set-env HOMEBREW_PREFIX '/usr/local'
	set-env HOMEBREW_CELLAR '/usr/local/Cellar'
}

echo (styled "\n!: last cmd | ⌃a,e: ⇄ | ^N: 🚀navigate | ⌃R: 🔍history | ^L: 🔍dirs | 💡 curl cheat.sh/?\n" bold italic)
