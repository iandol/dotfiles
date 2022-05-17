use re
use str
use path
use math
use epm
use platform
use cmds

################################################ Export Utils
var if-external~ = $cmds:if-external~
var is-path~ = $cmds:is-path~
var is-file~ = $cmds:is-file~
var is-macos~ = $cmds:is-macos~; var is-linux~ = $cmds:is-linux~

################################################ Abbreviations
set edit:abbr['||'] = '| less'
set edit:abbr['>dn'] = '2>/dev/null'
set edit:abbr['>so'] = '2>&1'
set edit:abbr['sudo '] = 'sudo -- '
# set edit:small-word-abbr['ll'] = 'ls -alFGh@'			
# set edit:small-word-abbr['ls'] = 'ls -GF'

################################################ Aliases
echo (styled "…loading command aliases…" bold italic white bg-blue)

if ( is-macos ) {
	edit:add-var lls~ {|@in| e:ls -alFGhtr@ $@in }
	edit:add-var lm~ {|@in| e:ls -alFGh@ $@in }
	edit:add-var ll~ {|@in| e:ls -alFGh $@in }
	edit:add-var ls~ {|@in| e:ls -GF $@in }
	edit:add-var manpdf~ {|@cmds|
		each {|c| man -t $c | open -f -a /System/Applications/Preview.app } $cmds
	}
	edit:add-var ql~ {|@in| e:qlmanage -p $@in }
	edit:add-var quicklook~ {|@in| e:qlmanage -p $@in }
	edit:add-var spotlighter~ {|@in| e:mdfind -onlyin (pwd) $@in }
	edit:add-var dequarantine~ {|@in| e:xattr -d com.apple.quarantine $@in }
	edit:add-var nitenite~ { e:exec pmset sleepnow }
} elif ( is-linux ) {
	edit:add-var ls~ {|@in| e:ls --color -GhFLH $@in }
	edit:add-var ll~ {|@in| e:ls --color -alFGh $@in }
}

if-external bat { edit:add-var cat~ {|@in| e:bat $@in }}
if-external python3 { edit:add-var urlencode~ {|@in| e:python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));" $@in } }

edit:add-var listUDP~ {|@in| 
	echo "Searching for: "$@in
	sudo lsof -i UDP -P | grep -E $@in
}
edit:add-var listTCP~ {|@in| 
	echo "Searching for: "$@in
	sudo lsof -i TCP -P | grep -E $@in
}

edit:add-var pp~ {|@in| pprint $@in }
edit:add-var sizes~ { e:du -sh * | e:sort -rh | e:bat --color never }
edit:add-var fs~ {|@in| e:du -sh $@in }
edit:add-var gst~ {|@in| e:git status $@in }
edit:add-var gca~ {|@in| e:git commit --all $@in }
edit:add-var resetorigin~ { e:git fetch origin; e:git reset --hard origin/master; e:git clean -f -d }
edit:add-var resetupstream~ { e:git fetch upstream; e:git reset --hard upstream/master; e:git clean -f -d }
edit:add-var untar~  {|@in| e:tar -zxvf $@in }
edit:add-var wget~  {|@in| e:wget -c $@in }
edit:add-var makepwd~ { e:openssl rand -base64 15 }
edit:add-var dl~  {|@in| e:curl -C - -O '{}' $@in }
edit:add-var ping~ {|@in| e:ping -c 5 $@in }
edit:add-var updatePip~ { pip install -U (pip freeze | each {|c| str:split "==" $c | cmds:first [(all)
] | echo (one) }) }
edit:add-var kittylight~ { sed -i '' 's/background_tint 0.755/background_tint 0.955/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes }
edit:add-var kittydark~ { sed -i '' 's/background_tint 0.955/background_tint 0.755/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes }

edit:add-var installTeX~ {
	sudo tlmgr install lualatex-math luatexja abstract ^
	latexmk csquotes pagecolor relsize mdframed needspace sectsty ^
	titling titlesec preprint layouts glossaries tabulary soul xargs todonotes ^
	mfirstuc xfor wallpaper datatool substr adjustbox collectbox ^
	sttools wrapfig footnotebackref fvextra zref ^
	libertinus libertsinus-fonts libertinus-otf threeparttable ^
	elsarticle algorithms algorithmicx siunitx bbding biblatex biber ctex ^
	stackengine xltabular booktabs orcidlink ^
	ltablex cleveref
}

edit:add-var update~ {
	echo (styled "\n====>>> Start Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
	var olddir = (pwd)
	var oldbranch = ''
	var ul = [.dotfiles Code/opticka Code/Titta Code/AfterImage Code/isoluminant Code/Pinna Code/spikes ^
	Code/Psychtoolbox-3 Code/fieldtrip Code/Training Code/Palamedes Code/Mymou ^
	Documents/MATLAB/gramm Code/scrivomatic Code/dotpandoc Code/bookends-tools ^
	Code/gears Code/pandocomatic Code/paru]
	for x $ul {
		if (is-path ~/$x/.git) {
			cd ~/$x
			set oldbranch = (git branch --show-current)
			var @branches = (git branch -l | each { |x| str:trim (str:trim-space $x) '* ' })
			echo (styled "\n--->>> Updating "(styled $x bold)":"$oldbranch"…\n" bg-blue)
			for x $branches {
				if (re:match '^(main|master|umaster)' $x) { git checkout $x }
			}
			try { git fetch --all 2>/dev/null; git pull 2>/dev/null; git status } catch e { echo "\t\t…couldn't pull!" }
			if (re:match 'upstream' (git remote | slurp)) {
				print "\t\t---> Fetching upstream…"
				try { git fetch -v upstream } catch e { echo "\t…couldn't fetch upstream!" }
			}
			git checkout $oldbranch
		}
	}
	cd $olddir
	if-external brew {
		echo (styled "\n\n---> Updating Homebrew...\n" bold bg-green)
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		try { brew update; brew outdated; brew upgrade } catch e { echo "\t\t …can't upgrade!"}
	}
	if (is-linux) {
		echo (styled "\n\n---> Updating APT…\n" bold bg-green)
		try {
		sudo apt update
		sudo apt autoremove
		apt list --upgradable
		if-external snap { sudo snap refresh }
		if-external fwupdmgr { fwupdmgr get-upgrades }
		} catch e {
			echo "\t…couldn't update APT or Snap or FWUPDATE!"
		}
	}
	if-external rbenv { echo "\n---> Rehash RBENV…\n"; rbenv rehash }
	if-external pyenv { echo "\n---> Rehash PYENV…\n"; pyenv rehash }
	if-external tlmgr { echo "\n---> Check TeX-Live…\n"; tlmgr update --list }
	echo (styled "\n\n---> Updating Elvish Packages…\n" bold bg-green)
	epm:upgrade
	echo (styled "\n====>>> Finish Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
}

edit:add-var updateElvish~ {
	if-external elvish { elvish -version }
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	var os = 'linux'; if (is-macos) { set os = 'darwin' }
	var pr = 'amd64'; if (eq (uname -m) 'aarch64') { set pr = 'aarch64'}
	curl -C - -O 'https://dl.elv.sh/'$os'-'$pr'/elvish-HEAD.tar.gz'
	tar xvf elvish-HEAD.tar.gz
	chmod +x elvish-HEAD
	sudo cp elvish-HEAD /usr/local/bin/elvish
	cd $olddir
	rm -rf $tmpdir
	if-external elvish { elvish -version }
}

edit:add-var updateFFmpeg~ {
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	var lver rver = '' ''
	cd $tmpdir
	if-external ffmpeg { set lver = (ffmpeg -version | grep -owE 'N-\d+-[^-]+') }
	var rver = "N-"(curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/snapshot | jq -r '.version')
	echo "\n===FFMPEG UPDATE===\nLocal: "$lver" & Remote: "$rver
	if (not (eq $lver $rver)) {
		echo '\tDownloading new ffmpeg:'
		curl -JL --output ff.7z https://evermeet.cx/ffmpeg/get
		7z -y -o$E:HOME/bin/ e ff.7z
		if (is-path $E:HOME"/Library/Application Support/FFmpegTools") {
			cp -f -v ~/bin/ffmpeg $E:HOME"/Library/Application Support/FFmpegTools/"
		}
		rm ff.7z
		ffmpeg -version
	} else {
		echo "\tNo need to update…"
	}
	cd $olddir
	rm -rf $tmpdir
}

edit:add-var updateOptickaPages~ {
	var opath = $E:HOME'/Code/opticka'
	if (is-path $opath) {
		echo "Trying to sync gh-pages from: "$opath
		var olddir = $pwd
		var tmpdir = (path:temp-dir)
		cd $opath
		var oldbranch = (git branch --show-current)
		git checkout master
		cp README.md $tmpdir
		git checkout gh-pages
		cp -f $tmpdir/README.md ./
		#git checkout $oldbranch
		#cd $olddir
		echo "Updated gh-pages from README.md"
		echo "Check and push manually..."
	}
}
