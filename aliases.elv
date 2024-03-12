use re
use str
use path
use math
use epm
use platform
use md
use github.com/iandol/elvish-modules/cmds # my utility module
echo (styled "…loading command aliases…" bold italic yellow)

#=================================================== - Abbreviations
#set edit:command-abbr['help'] = doc:show
set edit:abbr['||'] = '| less'
set edit:abbr['>dn'] = '2>/dev/null'
set edit:abbr['>so'] = '2>&1'
set edit:command-abbr['mm'] = 'micromamba'
set edit:command-abbr['edit'] = 'nvim'
set edit:command-abbr['arch'] = 'arch -x86_64'
# set edit:abbr['sudo '] = 'sudo -- '
# set edit:small-word-abbr['ll'] = 'ls -alFGh@'
# set edit:small-word-abbr['ls'] = 'ls -GF'

#==================================================== - ELVISH
edit:add-var help~ { |&search=$false @args| # from @krader https://skepticism.us/elvish/learn/useful-customizations.html#add-a-help-command
	use doc
	if (and (eq $search $false) (== 1 (count $args))) {
	try { doc:show $args[0] } catch { try { doc:show '$'$args[0] } catch { doc:find $args[0] } }
	} else { doc:find $@args }
}
edit:add-var pp~ {|@in| pprint $@in }
edit:add-var shortcuts~ { pprint $edit:insert:binding }

#==================================================== - LS
cmds:if-external lsd {
	edit:add-var llt~ {|@in| e:lsd --header --group-directories-first -alFht $@in }
	edit:add-var lls~ {|@in| e:lsd --header --group-directories-first -alFhS $@in }
	edit:add-var ll~ {|@in| e:lsd --header --group-directories-first -alFh $@in }
	edit:add-var ls~ {|@in| e:lsd -F $@in }
} {
	if ( cmds:is-macos ) { 
		edit:add-var lls~ {|@in| e:ls -alFGhS $@in }
		edit:add-var llt~ {|@in| e:ls -alFGht $@in }
		edit:add-var llm~ {|@in| e:ls -alFGh@ $@in }
		edit:add-var ll~ {|@in| e:ls -alFGh $@in }
		edit:add-var ls~ {|@in| e:ls -GF $@in }
	} else {
		edit:add-var ls~ {|@in| e:ls --color -GhFLH $@in }
		edit:add-var ll~ {|@in| e:ls --color -alFGh $@in }
	}
}

#==================================================== - GENERAL
edit:add-var installmicromamba~ { curl -L micro.mamba.pm/install.sh | zsh /dev/stdin }
if ( cmds:is-macos ) {
	edit:add-var mano~ { |@cmds|
		each {|c| mandoc -T pdf (man -w $c) | open -fa Preview.app } $cmds
	}
	if (cmds:is-file /usr/local/homebrew/bin/brew) { edit:add-var ibrew~ { |@in| arch -x86_64 /usr/local/homebrew/bin/brew $@in } }
	edit:add-var mbrew~ { |@in| arch -arm64e /opt/homebrew/bin/brew $@in }
	edit:add-var fix~ { |@in| e:codesign --force --deep -s - $@in }
	edit:add-var ql~ { |@in| e:qlmanage -p $@in }
	edit:add-var quicklook~ { |@in| e:qlmanage -p $@in }
	edit:add-var spotlighter~ { |@in| e:mdfind -onlyin (pwd) $@in }
	edit:add-var dequarantine~ { |@in| e:xattr -v -d com.apple.quarantine $@in }
	edit:add-var nitenite~ { e:exec pmset sleepnow }
	edit:add-var startarp~ {
		try { sudo launchctl start system/com.sangfor.EasyMonitor } catch { echo "EasyMonitor start error" }
		try { launchctl start gui/501/com.sangfor.ECAgentProxy } catch { echo "ECAgentProxy start error" }
		open "https://portal.arp.cn"
	}
	edit:add-var stoparp~ {
		try { sudo launchctl stop system/com.sangfor.EasyMonitor } catch { echo "Can't stop EasyMonitor" }
		try { launchctl stop gui/501/com.sangfor.ECAgentProxy } catch { echo "Can't stop ECAgentProxy" }
	}
} elif ( cmds:is-linux ) {
	edit:add-var mano~ {|@cmds|
		each {|c| man -Tps $c | ps2pdf - | zathura - & } $cmds
	}
	edit:add-var smbfix~ { kill (pidof gvfsd-smb-browse) }
	edit:add-var avahi-reset~ {
		sudo systemctl stop avahi-daemon.socket
		sudo systemctl stop avahi-daemon.service
		sudo systemctl start avahi-daemon.socket
		sudo systemctl start avahi-daemon.service
		sudo systemctl status avahi-daemon.service

	}
	edit:add-var avahi-stop~ {
		sudo systemctl stop avahi-daemon.socket
		sudo systemctl stop avahi-daemon.service
		sudo systemctl status avahi-daemon.service
	}

	edit:add-var installKitty~ { 
		curl -L sw.kovidgoyal.net/kitty/installer.sh | zsh /dev/stdin
		ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/bin
		cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
		cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
		sed -i "s|Icon=kitty|Icon="$E:HOME"/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
		sed -i "s|Exec=kitty|Exec="$E:HOME"/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
	}
}

cmds:if-external httping { edit:add-var hping~ {|@in| e:httping -K $@in } }
cmds:if-external bat { edit:add-var cat~ {|@in| e:bat -n $@in } }
cmds:if-external python3 { 
	edit:add-var urlencode~ { |@in| e:python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));" $@in } 
	edit:add-var urldecode~ { |@in| e:python3 -c "import sys, urllib.parse as ul; print(ul.unquote(sys.argv[1]));" $@in } 
}
cmds:if-external kitty {
	edit:add-var kssh~ { |@in| kitty +kitten ssh $@in }
	if (cmds:is-macos) {
		edit:add-var kittylight~ { sed -Ei '' 's/background_tint .+/background_tint 0.95/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes --reload-in=all }
		edit:add-var kittydark~ { sed -Ei '' 's/background_tint .+/background_tint 0.85/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes --reload-in=all }
	} else {
		edit:add-var kittylight~ { sed -Ei 's/background_tint .+/background_tint 0.95/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes --reload-in=all }
		edit:add-var kittydark~ { sed -Ei 's/background_tint .+/background_tint 0.85/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes --reload-in=all }
	}
}
cmds:if-external nvim { edit:add-var vi~ { |@in| nvim $@in }}

edit:add-var listUDP~ { |@in| 
	echo "Searching for: "$@in
	sudo lsof -i UDP -P | grep -E $@in
}
edit:add-var listTCP~ { |@in| 
	echo "Searching for: "$@in
	sudo lsof -i TCP -P | grep -E $@in
}

edit:add-var sizes~ { |@in| if (cmds:is-empty $in) { set @in = * }; e:du -sh $@in | e:sort -rh | cat }
edit:add-var fs~ { |@in| e:du -sh $@in | e:sort -rh } 
edit:add-var gst~ { |@in| e:git status $@in }
edit:add-var gca~ { |@in| e:git commit --all $@in }
edit:add-var resetorigin~ { e:git fetch origin; e:git reset --hard origin/master; e:git clean -f -d }
edit:add-var resetupstream~ { e:git fetch upstream; e:git reset --hard upstream/master; e:git clean -f -d }
edit:add-var untar~ { |@in| e:tar xvf $@in }
edit:add-var wget~ { |@in| e:wget -c $@in }
edit:add-var makepwd~ { e:openssl rand -base64 15 }
edit:add-var dl~ { |@in| e:curl -C - -O '{}' $@in }
edit:add-var ping~ { |@in| e:ping -c 5 $@in }
edit:add-var updatePip~ { pip install -U (pip freeze | each {|c| str:split "==" $c | cmds:first [(all)] }) }

#==================================================== - FUNCTIONS
# Filter the command history through the fzf program. This is normally bound
# to Ctrl-R.
fn history { 
	var new-cmd = (
		edit:command-history &dedup &newest-first &cmd-only |
		to-terminated "\x00" |
		try {
			fzf --tabstop=4 --color=dark --no-sort --read0 --layout=reverse --info=hidden --exact ^
			--query=$edit:current-command | slurp
		} catch {
			# If the user presses [Escape] to cancel the fzf operation it will exit
			# with a non-zero status. Ignore that we ran this function in that case.
			return
		}
	)
	set edit:current-command = (str:trim-right $new-cmd " \n")
}

fn get-messages {|&store=main|
	var p = "~/.config/elvish/store/"$store".json"
	var messages
	var syspromt = [&role=system &content="You are a helpful technical assistant that replies in english and explains your answers in detail"]
	if (cmds:is-file $p) { 
		set messages = (cmds:deserialise $p) 
	} else { set messages = [$syspromt] }
	put $messages
}
fn put-messages {|messages response &store=main|
	var p = "~/.config/elvish/store/"$store".json"
	var r = [&role=assistant &content=$response]
	var out = cmds:append $messages $r
	put $out
	cmds:serialise $p $out
}
fn clear-messages {|&store=main|
	var p = "~/.config/elvish/store/"$store".json"
	echo "Clearing messages from: "$p
	os:remove-all $p
}

edit:add-var ask~ {|q &model="hermes" &max=2048 &temperature=0.8|
	var models = [&hermes="Nous-Hermes-2-Mistral-7B-DPO.Q4_0.gguf" &openorca="mistral-7b-openorca.gguf2.Q4_0.gguf" &instruct="mistral-instruct-7b-2.43bpw.gguf" &instruct1="mistral-7b-instruct-v0.1.Q4_0.gguf" &phi="phi-2.Q4_K_S.gguf" &gemma="gemma-2b-it-q8_0.gguf"]
	if (has-key $models $model) { set model = $models[$model] }
	if (==s $model "") { set max = -1 }
	var messages = getMessages
	set q = [&role=user &content=$q]
	set messages = cmds:append $messages $q
	var message = (put [&model=$model &temperature=(num $temperature) &max_tokens=(num $max) &n=(num 1) &stream=false
		&messages=$messages] | to-json)
	put $message
	print "\n=============Question (model sent: "$model")\n\n"$q" … \n"
	var ans = (curl -s -X POST http://localhost:4891/v1/chat/completions -H "Content-Type: application/json" ^
		-H "Authorization: Bearer NO_API_KEY" ^
		-d $message | from-json)
	if (has-key $ans "model") { set model = [(str:split "/" $ans[model])][-1] } else { set model = "?" }
	print "\n=============Answer (model used:"$model")\n\n"
	var txt = (cmds:protect-brackets $ans[choices][0][message][content])
	md:show $txt
	putMessages $messages $txt
}

# --- Transfer a file (using either transfer.sh or 0x0.st)
edit:add-var transfer~ {|@in &use=transfer| 
	var url = ''
	if (==s $use "transfer") { set url = (e:curl --upload-file $@in 'https://transfer.sh/'$@in) 
	} else { set url = (e:curl -F 'file=@'$@in 'https://0x0.st') }
	echo "\n======================================================="
	md:show "The *online URL* for the file is: "$url
}

# --- Cl1p service
edit:add-var cl1p~ {|in name|
	var key = (e:cat ~/.cl1papitoken)
	e:curl -H "Content-Type: text/html; charset=UTF-8" -H "cl1papitoken: "$key -X POST --data $in https://api.cl1p.net/$name
	md:show (echo "Read data using `curl https://api.cl1p.net/"$name"`")
}

# --- Setproxy [-l] [address]
edit:add-var sp~ {|@argin|
	var @plist = {http,https,ftp,all}_proxy
	if (eq (count $argin) (num 1)) {
		if (eq $argin[0] "-l") {
			echo "Proxy settings:\n==============="
		} else {
			echo "Set proxy:\n==============="
			set-env no_proxy "localhost, 127.0.0.1, ::1"
			if (str:contains $argin[0] "socks5") {
				put $plist | cmds:flatten | each {|t| set-env $t $argin[0]; set-env (str:to-upper $t) $argin[0] }
			} elif (str:contains $argin[0] "http") {
				put $plist | cmds:flatten | each {|t| set-env $t "http://"$argin[0]; set-env (str:to-upper $t) $argin[0] }
			} else {
				put $plist | cmds:flatten | each {|t| set-env $t "http://"$argin[0]; set-env (str:to-upper $t) "http://"$argin[0] }
			}
			git config --global http.proxy $E:http_proxy
			git config --global https.proxy $E:https_proxy
		}
	} else {
		echo "Unset proxy:\n==============="
		unset-env no_proxy
		put $plist | cmds:flatten | each {|t| unset-env $t; unset-env (str:to-upper $t) }
		try { git config --global --unset http.proxy } catch { }
		try { git config --global --unset https.proxy } catch { }
	}
	echo "PROXY: HTTP = "$E:http_proxy" | HTTPS = "$E:https_proxy" | ALL = "$E:all_proxy "\nBYPASS: "$E:no_proxy
	try { echo "GIT: "(git config --global --get-regexp http | slurp | str:replace "\n" " " (one)) } catch { }
}
set edit:command-abbr['setproxy'] = 'sp'

# --- Install required TeX packages for BasicTex
# tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet
edit:add-var updateTeX~ {
	tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet
	tlmgr update --self
	tlmgr update --all
	tlmgr install lualatex-math luatexja abstract ^
	latexmk csquotes pagecolor relsize mdframed needspace sectsty ^
	titling titlesec preprint layouts glossaries tabulary soul xargs todonotes ^
	mfirstuc xfor wallpaper datatool substr adjustbox collectbox ^
	sttools wrapfig footnotebackref fvextra zref ^
	libertinus libertinus-fonts libertinus-otf threeparttable ^
	elsarticle algorithms algorithmicx siunitx bbding biblatex biber ^
	stackengine xltabular booktabs orcidlink ^
	ltablex cleveref makecell threeparttablex tabu multirow ^
	changepage marginnote sidenotes environ fontawesome5 tcolorbox framed pdfcol ^
	tikzfill luacolor lua-ul xpatch selnolig ^
	lua-visual-debug lipsum svg newfile
}

# --- Update code and OS
edit:add-var update~ {
	echo (styled "\n====>>> Start Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
	var olddir = (pwd)
	var oldbranch = ''
	var ul = [~/.dotfiles ~/Code/opticka ~/Code/octicka ~/Code/Titta ^
	~/Code/AfterImage ~/Code/equiluminance ~/Code/Pinna ~/Code/spikes ^
	~/Code/Psychtoolbox-3 ~/Code/fieldtrip ~/Code/Training ~/Code/Palamedes ^
	~/Code/Mymou ~/Documents/MATLAB/gramm ~/Code/scrivomatic ^
	~/Code/dotpandoc ~/Code/bookends-tools ^
	~/Code/gears ~/Code/pandocomatic ~/Code/paru ^
	/media/$E:USER/data/Code/octicka /media/$E:USER/data/Code/Psychtoolbox-3]
	for x $ul {
		if (cmds:is-path $x/.git) {
			tmp pwd = $x
			set oldbranch = (git branch --show-current)
			var @branches = (git branch -l | each { |x| str:trim (str:trim-space $x) '* ' })
			echo (styled "\n--->>> Updating "(styled $x bold)":"$oldbranch"…\n" bg-blue)
			for x $branches {
				if (re:match '^(main|master|umaster)' $x) { try { git checkout -q $x 2>$path:dev-null } catch { } }
			}
			try { git fetch -q --all 2>$path:dev-null; git pull } catch { echo "\t…couldn't pull!" }
			if (re:match 'upstream' (git remote | slurp)) {
				print "------> Fetching upstream…  "
				try { git fetch -v upstream } catch { echo "  …couldn't fetch upstream!" }
			}
			git checkout -q $oldbranch 2>$path:dev-null
		}
	}
	cd $olddir
	cmds:if-external brew {
		echo (styled "\n\n---> Updating Homebrew…\n" bold bg-color5)
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		try { 
			brew update; brew outdated
			brew upgrade --no-quarantine --display-times
			brew cleanup --prune=all
		} catch { echo "\t\t …can't upgrade!"}
	}
	if (cmds:is-macos) { try { echo (styled "\n\n---> Check macOS updates…\n" bold bg-color5); softwareupdate --list } catch { } }
	if (cmds:is-linux) {
		try { echo (styled "\n\n---> Updating APT…\n" bold bg-color5)
			sudo apt update
			sudo apt autoremove
			apt list --upgradable
		} catch { echo "\t…couldn't update APT!" }
		echo (styled "\n\n---> Updating snap/flatpak/firmware…\n" bold bg-color5)
		cmds:if-external snap { try { sudo snap refresh } catch { } }
		cmds:if-external flatpak { try { flatpak update -y } catch { } }
		cmds:if-external fwupdmgr { try { fwupdmgr get-upgrades } catch { } }
	}
	cmds:if-external micromamba { echo (styled "\n---> Update Micromamba…\n" bold bg-color5); micromamba self-update }
	cmds:if-external rbenv { echo (styled "\n---> Rehash RBENV…\n" bold bg-color5); rbenv rehash }
	cmds:if-external pyenv { echo (styled "\n---> Rehash PYENV…\n" bold bg-color5); pyenv rehash }
	try { cmds:if-external tlmgr { echo (styled "\n---> Check TeX-Live…\n" bold bg-color5); tlmgr update --list } } catch { }
	cmds:if-external vim {
		#echo (styled "\n\n---> Update VIM Plug.vim…\n" bold bg-color5)
		#try { curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim} catch { echo "Failed to download..." }
		#cmds:if-external nvim { echo "\t---> Update NVIM Plug.vim…\n"; mkdir -p $E:XDG_DATA_HOME/nvim/site/autoload; cp -v $E:HOME/.vim/autoload/plug.vim $E:XDG_DATA_HOME/nvim/site/autoload/ }
	}
	echo (styled "\n\n---> Updating Elvish Packages…\n" bold bg-color5)
	try { epm:upgrade } catch { echo "Couldn't update EPM packages…"}
	echo (styled "\n====>>> Finish Update @ "(styled (date) bold)" <<<====\n" italic fg-white bg-magenta)
}

# --- Update Elvish
edit:add-var updateElvish~ {|&source=tuna|
	var url = 'https://mirrors.tuna.tsinghua.edu.cn/elvish/'$platform:os'-'$platform:arch'/elvish-HEAD.tar.gz'
	if (!=s $source 'tuna') { set url = 'https://dl.elv.sh/'$platform:os'-'$platform:arch'/elvish-HEAD.tar.gz' }
	cmds:if-external elvish { elvish -version }
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	echo (styled "\n===GET ELVISH===\nURL: "$url bold yellow)
	try { wget --no-check-certificate $url
	} catch { echo "Couldn't download for some reason!" 
	} else { 
		tar xvf elvish-HEAD.tar.gz
		if (cmds:is-file ./elvish-HEAD) { mv ./elvish-HEAD ./elvish }
		chmod +x ./elvish
		sudo mv -vf ./elvish /usr/local/bin/elvish
		cmds:if-external elvish { elvish -version }
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}

# --- Update FFMPEG
edit:add-var updateFFmpeg~ {
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	var lv rv  = '' ''
	var os = $platform:os
	if (eq $os 'darwin') { set os = 'macos'}
	cmds:if-external ffmpeg { set lv = (ffmpeg -version | grep -owE 'ffmpeg version [^ :]+' | sed -E 's/ffmpeg version//g') }
	echo (styled "\n===FFMPEG UPDATE===\nOS: "$os" & Arch: "$platform:arch bold yellow)
	var tnames = [ffmpeg ffplay ffprobe]
	for x $tnames {
		try {
			wget --no-check-certificate -O $x.zip 'https://ffmpeg.martin-riedl.de/redirect/latest/'$os'/'$platform:arch'/snapshot/'$x'.zip'
			unzip -o $x.zip -d $E:HOME/bin/
		} catch { echo "Can't download "$x }
	}
	cmds:if-external ffmpeg { set rv = (ffmpeg -version | grep -owE 'ffmpeg version [^ :]+' | sed -E 's/ffmpeg version//g') }
	echo "===UPDATED:===\nOld: "$lv" & New: "$rv
	cd $olddir
	rm -rf $tmpdir
}

# --- Update Opticka
edit:add-var updateOptickaPages~ {
	var opath = $E:HOME'/Code/opticka'
	if (cmds:is-path $opath) {
		var olddir = $pwd
		cd $opath
		echo "Building HTML files vis Pandoc"
		var list = ["uihelpvars" "uihelpstims" "uihelpstate" "uihelpfunctions" "uihelptask"]
		for x $list {
			pandoc -d "help/help.yaml" -o "help/"$x".html" "help/"$x".md"
			}
		echo "Trying to sync gh-pages from: "$opath
		var tmpdir = (path:temp-dir)
		var oldbranch = (git branch --show-current)
		git checkout master
		cp README.md $tmpdir
		git checkout gh-pages
		cp -f $tmpdir/README.md ./
		#git checkout $oldbranch
		#cd $olddir
		echo "Updated gh-pages from README.md"
		echo "Check and push manually…"
	}
}
