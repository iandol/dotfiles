# elvish shell config: https://elv.sh/learn/tour.html
# see a sample here: https://gitlab.com/zzamboni/dot-elvish/-/blob/master/rc.org

################################################ https://elv.sh/ref/
use re
use str
use path
use math
use epm
use platform
if (and (not (path:is-regular &follow-symlink=$true ~/.config/elvish/lib/cmds.elv)) ^
(not (path:is-regular ~/.dotfiles/cmds.elv))) {
	ln -s ~/.dotfiles/cmds.elv ~/.config/elvish/lib/
}
use cmds
#use readline-binding

################################################ Key bindings
set edit:insert:binding[Ctrl-a] = $edit:move-dot-sol~
set edit:insert:binding[Ctrl-e] = $edit:move-dot-eol~

################################################ Paths
paths = [
	~/bin
	/usr/local/bin
	/usr/local/sbin
	$@paths
	/usr/sbin
	/sbin
	/usr/bin
	/bin
]
if ( has-external rbenv ) { paths = [~/.rbenv/shims/ $@paths] }
if ( path:is-dir /opt/local/bin ) { paths = [/opt/local/bin/ $@paths] }
each {|p|
	if (not (path:is-dir &follow-symlink $p)) {
		echo (styled "Warning: directory "$p" in $paths no longer exists." bg-red)
	}
} $paths

################################################ External modules
epm:install &silent-if-installed ^
	github.com/muesli/elvish-libs ^
	github.com/zzamboni/elvish-modules ^
	github.com/zzamboni/elvish-themes ^
	github.com/zzamboni/elvish-completions

#use github.com/muesli/elvish-libs/theme/powerline
use github.com/zzamboni/elvish-modules/proxy
use github.com/zzamboni/elvish-modules/alias
use github.com/zzamboni/elvish-completions/git
use github.com/zzamboni/elvish-completions/cd
use github.com/zzamboni/elvish-completions/ssh

# chain theme
use github.com/zzamboni/elvish-themes/chain
chain:init
chain:bold-prompt = $true
chain:show-last-chain = $false
chain:glyph[arrow] = "❯"
chain:prompt-segment-delimiters = [ "⟨" "⟩" ]

################################################ general ENV
if ( has-env PLATFORM ) {
	echo (styled "Elvish V"$version" running on "$E:PLATFORM bold italic bg-blue)
} else {
	set-env PLATFORM (uname -s)
	echo (styled "Elvish V"$version" running on "$E:PLATFORM bold italic bg-blue)
}

################################################ aliases
set alias:dir = ~/.config/elvish/aliases
if ( eq $platform:os "darwin" ) {
	alias:new lm e:ls -alFGh@
	alias:new ll e:ls -alFGh
	alias:new ls e:ls -GF
	edit:add-var manpdf~ {|@cmds|
		each {|c| man -t $c | open -f -a /System/Applications/Preview.app } $cmds
	}
	alias:new ql e:qlmanage -p
	alias:new quicklook e:qlmanage -p
	alias:new spotlighter e:mdfind -onlyin (pwd)
} elif ( eq $platform:os "linux" ) {
	alias:new ls e:ls --color -GhFLH
	alias:new ll e:ls --color -alFGh
}
alias:new gst e:git status
alias:new gca e:git commit --all
alias:new resetorigin { e:git fetch origin; e:git reset --hard origin/master; e:git clean -f -d }
alias:new resetupstream { e:git fetch upstream; e:git reset --hard upstream/master; e:git clean -f -d }
alias:new untar e:tar -zxvf 
alias:new wget e:wget -c 
alias:new makepwd e:openssl rand -base64 15
alias:new dl e:curl -C - -O '{}'
alias:new ping e:ping -c 5
var update~ = {
	echo (styled "\n====>>> Start Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
	var olddir = (pwd)
	var oldbranch = ''
	var ul = [.dotfiles Code/opticka Code/Titta ~
	Code/AfterImage Code/isoluminant Code/Pinna Code/spikes ~
	Code/Psychtoolbox-3 Code/fieldtrip ~
	Code/Training Code/Palamedes Code/Mymou ~
	Documents/MATLAB/gramm ~
	Code/scrivomatic Code/dotpandoc Code/bookends-tools Code/pandocomatic Code/paru]
	for x $ul {
		if (path:is-dir ~/$x/.git) {
			cd ~/$x
			set oldbranch = (git branch --show-current)
			var @branches = (git branch -l | each { |x| str:trim (str:trim-space $x) '* ' })
			echo (styled "\n--->>> Updating "(styled $x bold)":"$oldbranch"...\n" bg-blue)
			for x $branches {
				if (re:match '^(main|master|umaster)' $x) { git checkout $x }
			}
			try { git fetch --all 2>/dev/null; git pull 2>/dev/null } except e { echo "\t\t ...couldn't pull" }
			git status
			if (re:match 'upstream' (git remote | slurp)) {
				echo "\t\t---> Fetching upstream"
				git fetch -v upstream
			}
		}
	}
	cd $olddir
	if ( has-external brew ) {
		echo (styled "\n\n---> Updating Homebrew...\n" bold bg-green)
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		brew update; brew outdated; brew upgrade
	}
	if ( eq $platform:os "linux" ) {
		echo (styled "\n\n---> Updating APT...\n" bold bg-green)
		sudo apt update
		sudo apt autoremove
		apt list --upgradable
		if ( has-external snap ) { sudo snap refresh }
		if ( has-external fwupdmgr ) { fwupdmgr get-upgrades }
	}
	if ( has-external rbenv ) { echo "\n---> Rehash RBENV...\n"; rbenv rehash }
	echo (styled "\n\n---> Updating Elvish Packages...\n" bold bg-green)
	epm:upgrade
	echo (styled "\n====>>> Finish Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
}

var updateElvish~ = {
	cd (path:temp-dir)
	if ( eq $platform:os "darwin" ) {
		curl -C - -O https://dl.elv.sh/darwin-amd64/elvish-HEAD.tar.gz
	} elif ( eq $platform:os "linux" ) {
		curl -C - -O https://dl.elv.sh/linux-amd64/elvish-HEAD.tar.gz
	}
	tar xvf elvish-HEAD.tar.gz 
	chmod +x elvish-HEAD
	sudo cp elvish-HEAD /usr/local/bin/elvish
}

################################################ filtering functions
# var colors = [red orange yellow green blue purple]
# var cond = {|s| str:has-suffix $s 'e' }
# all $colors | filter-pipe { |in| re:match "e$" $in }
fn is-zero {|n| == 0 $n }
fn is-one {|n| == 1 $n }
fn is-even {|n| == (% $n 2) 0 }
fn is-odd {|n| == (% $n 2) 1 }
fn dec {|n| - $n 1 }
fn inc {|n| + $n 1 }
fn pos {|n| > $n 0 }
fn neg {|n| < $n 0 }
fn is-fn {|x| eq (kind-of $x) fn }
fn is-map {|x| eq (kind-of $x) map }
fn is-list {|x| eq (kind-of $x) list }
fn is-string {|x| eq (kind-of $x) string }
fn is-bool {|x| eq (kind-of $x) bool }
fn is-number {|x| eq (kind-of $x) !!float64 }
fn is-ok {|x| eq $x $ok }
fn is-nil {|x| eq $x $nil }
fn is-empty {|li| is-zero (count $li) }
fn check-pipe {|@li| # use when taking @args
	if (is-empty $li) { all } else { all $li }
}
fn repeat-each {|n f|
	for i [(range 0 $n)] { $f }
}
fn hexstring {|n|
	put (repeat-each $n { printf '%X' (randint 0 16) })
}
fn match {|in re| re:match $re $in }
fn filter {|cond re @in| 
	if (eq $in []) {
		each {|item| if ($cond $item $re) { put $item } } 
	} else {
		each {|item| if ($cond $item $re) { put $item } } $@in
	}
}
fn filterp {|cond @in| 
	if (eq $in []) {
		peach {|item| if ($cond $item) { put $item } } 
	} else {
		peach {|item| if ($cond $item) { put $item } } $@in
	}
}

################################################ setup brew
if ( and (eq $platform:os 'linux') (path:is-dir &follow-symlink /home/linuxbrew/.linuxbrew/bin/) ) {
	echo (styled "\t…configuring Linux brew…\n" bold bg-blue)
	paths = [
		/home/linuxbrew/.linuxbrew/bin/
		/home/linuxbrew/.linuxbrew/sbin/
		$@paths
	]
} elif ( and (eq $platform:os 'darwin') (path:is-dir &follow-symlink /home/) ) {
	echo (styled "\t…configuring Darwin brew…\n" bold bg-blue)
	set-env HOMEBREW_PREFIX '/usr/local'
	set-env HOMEBREW_CELLAR '/usr/local/Cellar'
}

echo (styled "\n⌃a,e: ⇄ | ^N: 🚀navigate | ⌃R: 🔍history | ^L: 🔍dirs | 💡 curl cheat.sh/?\n" bold italic)
