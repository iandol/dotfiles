use re
use str
use path
use math
use epm
use platform
use md
use os
use github.com/iandol/elvish-modules/cmds # my utility module
echo (styled "…loading command aliases…" bold italic yellow)

#=================================================== - Abbreviations
#set edit:command-abbr['help'] = doc:show
set edit:abbr['||'] = '| less'
set edit:abbr['>dn'] = '2>/dev/null'
set edit:abbr['>so'] = '2>&1'
set edit:command-abbr['xp'] = 'x proxy set 127.0.0.1:'
set edit:command-abbr['xpu'] = 'x proxy unset'
set edit:command-abbr['mm'] = 'micromamba'
set edit:command-abbr['edit'] = 'nvim'
set edit:command-abbr['arch'] = 'arch -x86_64'
# set edit:abbr['sudo '] = 'sudo -- '
# set edit:small-word-abbr['ll'] = 'ls -alFGh@'
# set edit:small-word-abbr['ls'] = 'ls -GF'

#==================================================== - ELVISH
edit:add-var pp~ {|@in| pprint $@in }
edit:add-var shortcuts~ { pprint $edit:insert:binding }
fn helpme { echo (styled "
! – last cmd 🔘 ⌃N – 🚀navigate 🔘 ⌃R – 🔍history 🔘 ⌃L – 🔍dirs
⌃B – 🖊️cmd 🔘 ⌃a,e – ⇄ 🔘 ⌃u – ⌫line 🔘 💡 curl cheat.sh/?
[VIM] :e load-buf 🔘 :bn next-buf 🔘 :ls list-buf 🔘 :bd close-buf
  :tab ba buf>tabs 🔘 gt next-tab 🔘 :vert ba vertical
  ^w[s|v] split-viewport 🔘 ^ww switch-vp 🔘 ^wx exchange-vp
  [N]yy=yank 🔘 [N]dd=cut 🔘 p=paste 🔘 *# jump to word
  / pattern-search 🔘 n=next
[TMUX] prefix §=^a 🔘 tmux-pane: split=§| §- close=§x focus=§o
  sessions=§s detach=§d window-create=§c switch=§n close=§&
  commands=§: help=§? navigate=§w" bold italic fg-yellow ) }
edit:add-var helpme~ $helpme~

#==================================================== - LS, prefer lsd if available
cmds:if-external lsd {
	edit:add-var llt~ {|@in| e:eza --icons=auto -al -r -s time --group-directories-first $@in }
	edit:add-var lls~ {|@in| e:eza --icons=auto -al -r -s size --group-directories-first $@in }
	edit:add-var lll~ {|@in| e:eza --icons=auto --git -alO@ --group-directories-first $@in }
	edit:add-var ll~ {|@in| e:eza --icons=auto -al --group-directories-first $@in }
	edit:add-var ls~ {|@in| e:eza --icons=auto --group-directories-first $@in }
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
	edit:add-var iterm~ { arch -x86_64 /System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal &}
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
		open "https://newvpn.arp.cn/com/installClient.html"
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
	# Linux way to update/install kitty
	edit:add-var installKitty~ { 
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
		ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
		cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
		cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
		sed -i "s|Icon=kitty|Icon=/home/"$E:USER"/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
		sed -i "s|Exec=kitty|Exec=/home/"$E:USER"/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
		echo "kitty.desktop" > ~/.config/xdg-terminals.list
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
cmds:if-external nvim { edit:add-var vi~ $e:nvim~ }

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
# from @krader https://skepticism.us/elvish/learn/useful-customizations.html#add-a-help-command
fn help { |&search=$false @args|
	use doc
	if (and (eq $search $false) (== 1 (count $args))) {
	try { doc:show $args[0] } catch { try { doc:show '$'$args[0] } catch { doc:find $args[0] } }
	} else { doc:find $@args }
}
edit:add-var help~ $help~

# edit current command in editor, from @Kurtis-Rader set edit:insert:binding[Ctrl-b] = { aliases:external-edit-command }
fn external-edit-command {
	var temp-file = (os:temp-file '*.elv')
	echo $edit:current-command > $temp-file
	try {
		(external $E:EDITOR) $temp-file[name] <$os:dev-tty >$os:dev-tty 2>&1
		set edit:current-command = (str:trim-right (slurp < $temp-file[name]) " \n")
	} finally {
		file:close $temp-file
		os:remove $temp-file[name]
	}
}

# Filter the command history through the fzf program. This is normally bound
# to Ctrl-R. set edit:insert:binding[Ctrl-R] = { aliases:history >/dev/tty 2>&1 }
fn history { 
	if ( not (has-external "fzf") ) {
		edit:history:start
		return
	}
	var new-cmd = (
		edit:command-history &dedup &newest-first &cmd-only |
		to-terminated "\x00" |
		try {
			fzf --tabstop=2 --color=dark --no-sort --read0 --layout=reverse --info=hidden --exact ^
			--query=$edit:current-command | slurp | str:trim-space (all)
		} catch {
			# If the user presses [Escape] to cancel the fzf operation it will exit
			# with a non-zero status. Ignore that we ran this function in that case.
			edit:redraw &full=$true
			return
		}
	)
	edit:redraw &full=$true
	set edit:current-command = $new-cmd
}

# --- Transfer a file (using either transfer.sh or 0x0.st)
fn transfer {|@in &use=transfer| 
	var url = ''
	if (==s $use "transfer") { set url = (e:curl --upload-file $@in 'https://transfer.sh/'$@in) 
	} else { set url = (e:curl -F 'file=@'$@in 'https://0x0.st') }
	echo "\n======================================================="
	md:show "The *online URL* for the file is: "$url
}
edit:add-var transfer~ $transfer~

# --- Cl1p service
fn cl1p {|in name|
	var key = (e:cat ~/.cl1papitoken)
	e:curl -H "Content-Type: text/html; charset=UTF-8" -H "cl1papitoken: "$key -X POST --data $in https://api.cl1p.net/$name
	md:show (echo "Read data using `curl https://api.cl1p.net/"$name"`")
}
edit:add-var cl1p~ $cl1p~

# --- Setproxy [-l] [address]
fn sp {|@argin|
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
edit:add-var sp~ $sp~
set edit:command-abbr['setproxy'] = 'sp'

# --- Install required TeX packages for BasicTex
# tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet
fn updateTeX {|&repo=tuna|
	if (==s $repo tuna) { tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet } else { tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet }
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
edit:add-var updateTeX~ $updateTeX~

# --- Update code and OS
fn update {
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
edit:add-var update~ $update~

# --- Update Elvish
fn updateElvish {|&source=tuna|
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
edit:add-var updateElvish~ $updateElvish~

# --- Update FFMPEG
fn updateFFmpeg {
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
edit:add-var updateFFmpeg~ $updateFFmpeg~

# --- Update Opticka
fn updateOptickaPages {
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
edit:add-var updateOptickaPages~ $updateOptickaPages~
