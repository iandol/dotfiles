use re
use str
use path
use math
use epm
use platform
use cmds
# use github.com/zzamboni/elvish-modules/alias
# set alias:dir = ~/.config/elvish/aliases

################################################ Export Utils
var only-when-external~ = $cmds:only-when-external~

echo (styled "…loading command aliases…" bold italic white bg-blue)

if ( eq $platform:os "darwin" ) {
	edit:add-var lm~ {|@in| e:ls -alFGh@ $@in }
	edit:add-var ll~ {|@in| e:ls -alFGh $@in }   # set edit:small-word-abbr['ll'] = 'ls -alFGh@'
	edit:add-var ls~ {|@in| e:ls -GF $@in } # set edit:small-word-abbr['ls'] = 'ls -GF'
	edit:add-var manpdf~ {|@cmds|
		each {|c| man -t $c | open -f -a /System/Applications/Preview.app } $cmds
	}
	edit:add-var ql~ {|@in| e:qlmanage -p $@in }
	edit:add-var quicklook~ {|@in| e:qlmanage -p $@in }
	edit:add-var spotlighter~ {|@in| e:mdfind -onlyin (pwd) $@in }
} elif ( eq $platform:os "linux" ) {
	edit:add-var ls~ {|@in| e:ls --color -GhFLH $@in }
	edit:add-var ll~ {|@in| e:ls --color -alFGh $@in }
}

edit:add-var gst~ {|@in| e:git status $@in }
edit:add-var gca~ {|@in| e:git commit --all $@in }
edit:add-var resetorigin~ { e:git fetch origin; e:git reset --hard origin/master; e:git clean -f -d }
edit:add-var resetupstream~ { e:git fetch upstream; e:git reset --hard upstream/master; e:git clean -f -d }
edit:add-var untar~  {|@in| e:tar -zxvf $@in }
edit:add-var wget~  {|@in| e:wget -c $@in }
edit:add-var makepwd~ { e:openssl rand -base64 15 }
edit:add-var dl~  {|@in| e:curl -C - -O '{}' $@in }
edit:add-var ping~ {|@in| e:ping -c 5 $@in }

edit:add-var update~ {
	echo (styled "\n====>>> Start Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
	var olddir = (pwd)
	var oldbranch = ''
	var ul = [.dotfiles Code/opticka Code/Titta Code/AfterImage Code/isoluminant Code/Pinna Code/spikes ^
	Code/Psychtoolbox-3 Code/fieldtrip Code/Training Code/Palamedes Code/Mymou ^
	Documents/MATLAB/gramm Code/scrivomatic Code/dotpandoc Code/bookends-tools ^
	Code/pandocomatic Code/paru]
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
	only-when-external brew {
		echo (styled "\n\n---> Updating Homebrew...\n" bold bg-green)
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		brew update; brew outdated; brew upgrade
	}
	if ( eq $platform:os "linux" ) {
		echo (styled "\n\n---> Updating APT...\n" bold bg-green)
		sudo apt update
		sudo apt autoremove
		apt list --upgradable
		only-when-external snap { sudo snap refresh }
		only-when-external fwupdmgr { fwupdmgr get-upgrades }
	}
	only-when-external rbenv { echo "\n---> Rehash RBENV...\n"; rbenv rehash }
	echo (styled "\n\n---> Updating Elvish Packages...\n" bold bg-green)
	epm:upgrade
	echo (styled "\n====>>> Finish Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
}

edit:add-var updateElvish~ {
	var old_dir = $pwd
	var tmp_dir = (path:temp-dir)
	cd $tmp_dir
	if ( eq $platform:os "darwin" ) {
		curl -C - -O https://dl.elv.sh/darwin-amd64/elvish-HEAD.tar.gz
	} elif ( eq $platform:os "linux" ) {
		curl -C - -O https://dl.elv.sh/linux-amd64/elvish-HEAD.tar.gz
	}
	tar xvf elvish-HEAD.tar.gz 
	chmod +x elvish-HEAD
	sudo cp elvish-HEAD /usr/local/bin/elvish
	cd $old_dir
	rm -rf $tmp_dir
}

edit:add-var updateFFmpeg~ {
	var old_dir = $pwd
	var tmp_dir = (path:temp-dir)
	cd $tmp_dir
	var lver = (ffmpeg -version | grep -owE 'N-\d+-[^-]+')
	var rver = "N-"(curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/snapshot | jq -r '.version')
	echo "\n===FFMPEG UPDATE===\nLocal: "$lver" & Remote: "$rver
	if (not (eq $lver $rver)) {
		echo '\tDownloading new ffmpeg:'
		curl -JL --output ff.7z https://evermeet.cx/ffmpeg/get
		7z -y -o ~/bin/ e ff.7z
		cp ~/bin/ffmpeg "~/Library/Application Support/FFmpegTools/"
		rm ff.7z
		ffmpeg -version
	} else {
		echo "\tNo need to update…"
	}
	cd $old_dir
	rm -rf $tmp_dir
}
