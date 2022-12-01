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
var flatten~ = $cmds:flatten~

################################################ Abbreviations
set edit:abbr['||'] = '| less'
set edit:abbr['>dn'] = '2>/dev/null'
set edit:abbr['>so'] = '2>&1'
# set edit:abbr['sudo '] = 'sudo -- '
# set edit:small-word-abbr['ll'] = 'ls -alFGh@'			
# set edit:small-word-abbr['ls'] = 'ls -GF'

################################################ Aliases
echo (styled "…loading command aliases…" bold italic white)

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
	edit:add-var dequarantine~ {|@in| e:xattr -v -d com.apple.quarantine $@in }
	edit:add-var nitenite~ { e:exec pmset sleepnow }
} elif ( is-linux ) {
	edit:add-var ls~ {|@in| e:ls --color -GhFLH $@in }
	edit:add-var ll~ {|@in| e:ls --color -alFGh $@in }
}

if-external bat { edit:add-var cat~ {|@in| e:bat $@in }}
if-external python3 { edit:add-var urlencode~ {|@in| e:python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));" $@in } }
if-external kitty { edit:add-var kssh~ {|@in| kitty +kitten ssh $@in } }
if-external nvim { edit:add-var vi~ {|@in| nvim $@in }}

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

edit:add-var startarp~ { sudo launchctl start com.sangfor.EasyMonitor; launchctl start com.sangfor.ECAgentProxy; open "https://portal.arp.cn" }
edit:add-var stoparp~ { sudo launchctl stop com.sangfor.EasyMonitor; launchctl stop com.sangfor.ECAgentProxy; }

edit:add-var setproxy~ { |@argin|
	var @plist = {http,https,ftp,all}_proxy
	if (eq (count $argin) (num 1)) {
		if (eq $argin[0] "-l") {
			echo "Proxy Settings:"
		} else {
			echo "Proxy set: " 
			set-env no_proxy "localhost, 127.0.0.1, ::1"
			put $plist | cmds:flatten | each {|t| set-env $t $argin[0]}
			if (str:contains $argin[0] "socks5") {
				git config --global http.proxy $E:http_proxy
				git config --global https.proxy $E:https_proxy
			} else {
				git config --global http.proxy "http://"$E:http_proxy
				git config --global https.proxy "https://"$E:https_proxy
			}
		}
	} else {
		echo "Will unset the proxy..."
		unset-env no_proxy
		put $plist | cmds:flatten | each {|t| unset-env $t}
		try { git config --global --unset http.proxy } catch { }
		try { git config --global --unset https.proxy } catch { }
	}
	echo "PROXY: HTTP = "$E:http_proxy" | HTTPS = "$E:https_proxy" | ALL = "$E:all_proxy
	echo "BYPASS: "$E:no_proxy
	try { echo "GIT:"(git config --global --get-regexp http)"\n" } catch { }
}

edit:add-var installTeX~ {
	sudo tlmgr install lualatex-math luatexja abstract ^
	latexmk csquotes pagecolor relsize mdframed needspace sectsty ^
	titling titlesec preprint layouts glossaries tabulary soul xargs todonotes ^
	mfirstuc xfor wallpaper datatool substr adjustbox collectbox ^
	sttools wrapfig footnotebackref fvextra zref ^
	libertinus libertinus-fonts libertinus-otf threeparttable ^
	elsarticle algorithms algorithmicx siunitx bbding biblatex biber ctex ^
	stackengine xltabular booktabs orcidlink ^
	ltablex cleveref makecell threeparttablex tabu multirow ^
	changepage marginnote sidenotes environ fontawesome5
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
			try { git fetch --all 2>/dev/null; git pull 2>/dev/null; git status } catch { echo "\t\t…couldn't pull!" }
			if (re:match 'upstream' (git remote | slurp)) {
				print "\t\t---> Fetching upstream…"
				try { git fetch -v upstream } catch { echo "\t…couldn't fetch upstream!" }
			}
			git checkout $oldbranch
		}
	}
	cd $olddir
	if-external brew {
		echo (styled "\n\n---> Updating Homebrew...\n" bold bg-red)
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		try { brew update; brew outdated; brew upgrade; brew cleanup } catch { echo "\t\t …can't upgrade!"}
	}
	if (is-linux) {
		echo (styled "\n\n---> Updating APT…\n" bold bg-red)
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
	try { if-external tlmgr { echo "\n---> Check TeX-Live…\n"; tlmgr update --list } } catch { }
	if-external vim {
		echo "\n---> Update VIM Plug.vim…\n"; 
		try { curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim} catch { echo "Failed to download..." }
	}
	if-external nvim { echo "\n---> Update NVIM Plug.vim…\n"; mkdir -p $E:XDG_DATA_HOME/nvim/site/autoload; cp -v $E:HOME/.vim/autoload/plug.vim $E:XDG_DATA_HOME/nvim/site/autoload/ }
	echo (styled "\n\n---> Updating Elvish Packages…\n" bold bg-red)
	try { epm:upgrade } catch { echo "Couldn't update EPM packages..."}
	echo (styled "\n====>>> Finish Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
}

edit:add-var updateElvish~ {
	if-external elvish { elvish -version }
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	var os = 'linux'; if (is-macos) { set os = 'darwin' }
	var pr = 'amd64'; 
	if (or (eq (uname -m) 'arm64') (eq (uname -m) 'aarch64')) { set pr = 'arm64'}
	echo "\n===ELVISH===\nOS: "$os" & Arch: "$pr
	curl -C - -O 'https://mirrors.tuna.tsinghua.edu.cn/elvish/'$os'-'$pr'/elvish-HEAD.tar.gz'
	tar xvf elvish-HEAD.tar.gz
	chmod +x elvish-HEAD
	sudo mv -vf elvish-HEAD /usr/local/bin/elvish
	cd $olddir
	rm -rf $tmpdir
	if-external elvish { elvish -version }
}

edit:add-var updateFFmpeg~ {
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	var lver rver lverp rverp = '' '' '' ''
	cd $tmpdir
	if-external ffmpeg { set lver = (ffmpeg -version | grep -owE 'N-\d+-[^- ]+') }
	if-external ffplay { set lverp = (ffplay -version | grep -owE 'N-\d+-[^- ]+') }
	if (eq (uname -m) 'arm64') {
		echo "\tDownloading ARM64 ffmpeg:"
		curl -JL --output ff.zip https://ffmpeg.martin-riedl.de/redirect/latest/macos/arm64/snapshot/ffmpeg.zip
		unzip -o ff.zip -d $E:HOME/bin/
		curl -JL --output fp.zip https://ffmpeg.martin-riedl.de/redirect/latest/macos/arm64/snapshot/ffplay.zip
		unzip -o fp.zip -d $E:HOME/bin/
		if-external ffmpeg { set rver = (ffmpeg -version | grep -owE 'N-\d+-[^- ]+') }
		if-external ffplay { set rverp = (ffplay -version | grep -owE 'N-\d+-[^- ]+') }
		echo "\n===FFMPEG UPDATE===\nOld: "$lver" & New: "$rver
		echo "\n===FFPLAY UPDATE===\nOld: "$lverp" & New: "$rverp
	} else {
		var rver = "N-"(curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/snapshot | jq -r '.version')
		var rverp = "N-"(curl -s https://evermeet.cx/ffplay/info/ffplay/snapshot | jq -r '.version')
		echo "\n===FFMPEG UPDATE===\nLocal: "$lver" & Remote: "$rver
		if (not (eq $lver $rver)) {
			echo "\tDownloading new ffmpeg:"
			curl -JL --output ff.7z https://evermeet.cx/ffmpeg/get
			7z -y -o$E:HOME/bin/ e ff.7z
			if (is-path $E:HOME"/Library/Application Support/FFmpegTools") {
				cp -f -v ~/bin/ffmpeg $E:HOME"/Library/Application Support/FFmpegTools/"
			}
			rm ff.7z
			ffmpeg -version
		} else {
			echo "\tNo need to update ffmpeg…"
		}
		echo "\n===FFPLAY UPDATE===\nLocal: "$lverp" & Remote: "$rverp
		if (not (eq $lverp $rverp)) {
			echo "\tDownloading new ffplay:"
			curl -JL --output fp.7z https://evermeet.cx/ffmpeg/get/ffplay
			7z -y -o$E:HOME/bin/ e fp.7z
			rm fp.7z
			ffplay -version
		} else {
			echo "\tNo need to update ffplay"
		}
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
