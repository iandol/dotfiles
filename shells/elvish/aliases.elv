use re; use str; use path; use file; use math; use epm; use platform; use md; use os; use flag
use github.com/iandol/elvish-modules/cmds # my utility module
fn msg { |@t| echo (styled "👉🏼 "$@t bold italic yellow) }
fn header1 { |@t| echo (styled "\n\n   🌕===   "$@t"   ===🌕   " bold italic inverse magenta) }
fn header2 { |@t| echo (styled "\n\n   🌗===   "$@t"   ===🌓   " bold italic inverse yellow) }
msg "…loading command aliases…"

#=================================================== - Abbreviations
#set edit:command-abbr['help'] = doc:show
set edit:abbr['||'] = '| less'
set edit:abbr['>dn'] = '2>/dev/null'
set edit:abbr['>eo'] = '2>&1'
set edit:command-abbr['cd'] = 'z' #switch to zoxide
set edit:command-abbr['lz'] = 'lazygit' #git tui
set edit:command-abbr['curld'] = 'curl --retry 5 -L -C -'
set edit:command-abbr['xp'] = 'x proxy set 127.0.0.1:'
set edit:command-abbr['xpu'] = 'x proxy unset'
set edit:command-abbr['sds'] = 'sudo -E systemctl status'
set edit:command-abbr['sdu'] = 'systemctl --user status'
set edit:command-abbr['ju'] = 'journalctl --user --all -f -u'
set edit:command-abbr['js'] = 'journalctl --all -f -u'
set edit:command-abbr['edit'] = 'nvim'
set edit:command-abbr['arch'] = 'arch -x86_64'
# set edit:abbr['sudo '] = 'sudo -- '
# set edit:small-word-abbr['ll'] = 'ls -alFGh@'
# set edit:small-word-abbr['ls'] = 'ls -GF'

#==================================================== - ELVISH
edit:add-var pp~ {|@in| pprint $@in }
edit:add-var shortcuts~ { pprint $edit:insert:binding }
fn helpme { echo (styled "
! – last cmd │ ⌃N – 🚀navigate │ ⌃R – 🔍history │ ⌃L – 🔍dirs
⌃B – 🖊️cmd │ ⌃a,e – ⇄ │ ⌃u – ⌫line │ 💡 curl cheat.sh/?
┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
ᵛᴵᵐ :e load-buf │ :bn next-buf │ :ls list-buf │ :bd close-buf
  :tab ba buf>tabs │ gt next-tab │ :vert ba vertical
  ^w [s|v] split-viewport │ ^ww switch-vp │ ^wx exchange-vp
  <#>yy=yank │ <#>dd=cut │ p=paste │ *# jump to word
  q[a-z]=macro │ @[a-z]=replay │ :reg=list registers
  / pattern-search │ n=next │ :%s/a/b/g global a>b replace
┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
ᵀᵪ ●=prefix ^a │ tmux-pane: split=●| ●- close=●x focus=●o
  sessions=●s detach=●d window-create=●c switch=●n close=●&
  commands=●: help=●? navigate=●w\n" bold '#FFCC99' ) }
edit:add-var helpme~ $helpme~

#==================================================== - KITTY
edit:add-var kittymap~ { cat ~/.config/kitty/kitty.map | fzf --ansi --style full }
cmds:if-external kitty {
	edit:add-var kittydef~ {  kitty +runpy 'from kitty.config import *; print(commented_out_default_config())' > $E:HOME/.dotfiles/terminals/kitty/kitty-default.conf }
	edit:add-var kssh~ { |@in| kitten ssh $@in --kitten login_shell=elvish }
	edit:add-var kittylight~ { sed -Ei '' 's/background_tint .+/background_tint 0.55/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes --reload-in=all }
	edit:add-var kittydark~ { sed -Ei '' 's/background_tint .+/background_tint 0.85/g' ~/.dotfiles/configs/kitty.conf; kitty +kitten themes --reload-in=all }	
}

#==================================================== - YAZI
edit:add-var y~ {|@argv|
	var tmp = (os:temp-file)
	yazi $@argv --cwd-file=$tmp[name]
	var cwd = (slurp < $tmp)
	file:close $tmp
	os:remove $tmp[name]
	if (and (not-eq $cwd '') (not-eq $cwd $pwd)) { cd $cwd }
}

#==================================================== - AEROSPACE
edit:add-var as~ { aerospace list-windows --all | fzf --height 20 --bind 'enter:execute($SHELL -c "aerospace focus --window-id {1}")+abort' }

#==================================================== - LS, prefer EZA if available
cmds:if-external eza {
	edit:add-var llt~ {|@in| e:eza --icons=auto --git -al -r -s time --group-directories-first $@in }
	edit:add-var lls~ {|@in| e:eza --icons=auto --git -al -r -s size --group-directories-first $@in }
	edit:add-var lll~ {|@in| e:eza --icons=auto --git -alO@ --group-directories-first $@in }
	edit:add-var ll~ {|@in| e:eza --icons=auto --git -al --group-directories-first $@in }
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

#==================================================== - How to reset a Linux clone
fn cloneReset { |hostname|
	# This function resets the machine ID and hostname for a Linux clone. It
	# is useful when you clone a VM or a machine and want to avoid conflicts
	# with the original machine. It will also reset the SSH host keys and
	# prompt how to add a new profile in netbird. 
	#
	# Usage: cloneReset <new-hostname> 
	# Example: cloneReset my-new-hostname 
	#
	# https://gist.github.com/iandol/85f663cf670cb3b94ea1b661757bb356
	if (not $hostname) { msg "Usage: cloneReset <new-hostname>"; return }
	if (not (cmds:is-linux)) { return }
	hostnamectl
	msg "Old Machine ID: "(e:cat /etc/machine-id)" Old Hostname: "(e:cat /etc/hostname)
	sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
	sudo dbus-uuidgen --ensure=/etc/machine-id
	hostnamectl set-hostname $hostname
	sudo sed -i.bak -E 's/^[[:space:]]*127\.0\.1\.1.*/127.0.1.1 '$hostname'/' /etc/hosts
	msg "New Machine ID: "(e:cat /etc/machine-id)" New Hostname: "(e:cat /etc/hostname)
	try { sudo rm -f /etc/ssh/ssh_host_*
	sudo dpkg-reconfigure openssh-server
	sudo systemctl restart ssh } catch { echo "SSH host keys reset failed" }
	msg "For netbird, you must [netbird profile add newprofile] and then [netbird profile select] it"
}
edit:add-var cloneReset~ $cloneReset~

#==================================================== - GENERAL
edit:add-var installmicromamba~ { curl -L micro.mamba.pm/install.sh | zsh /dev/stdin }
edit:add-var cagelab-monitor~ { tmuxp load cagelab-monitor }
edit:add-var cagelab-zsh~ { ln -svf $E:HOME/Code/Setup/config/zshrc $E:HOME/.zshrc; ln -svf $E:HOME/Code/Setup/config/zsh-* $E:HOME; ln -svf $E:HOME/Code/Setup/config/aliases $E:HOME }
edit:add-var cagelab-reset~ { systemctl --user restart cogmoteGO; systemctl --user restart theConductor }
edit:add-var cagelab-reset-OBS~ {'systemctl --user stop mediamtx; systemctl --user stop obs; sleep 1; systemctl --user start mediamtx; systemctl --user start obs' }
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
cmds:if-external nvim { edit:add-var vi~ $e:nvim~ }

edit:add-var listUDP~ { |@in|
	msg "Searching for: "$@in
	sudo lsof -i UDP -P | grep -E $@in }
edit:add-var listTCP~ { |@in|
	msg "Searching for: "$@in
	sudo lsof -i TCP -P | grep -E $@in }

edit:add-var myip~ { e:curl -s ipinfo.io/ip }
edit:add-var sizes~ { |@in| if (cmds:is-empty $in) { set @in = * }; e:du -sh $@in | e:sort -rh | cat }
edit:add-var fs~ { |@in| e:du -sh $@in | e:sort -rh } 
edit:add-var gst~ { |@in| e:git status $@in }
edit:add-var gca~ { |@in| e:git commit --all $@in }
edit:add-var gitResetOrigin~ { e:git fetch origin; e:git reset --hard origin/master; e:git clean -f -d }
edit:add-var gitResetUpstream~ { e:git fetch upstream; e:git reset --hard upstream/master; e:git clean -f -d }
edit:add-var untar~ { |@in| e:tar xvf $@in }
edit:add-var wget~ { |@in| e:wget -c $@in }
edit:add-var makepwd~ { e:openssl rand -base64 15 }
edit:add-var dl~ { |@in| e:curl -C - -O '{}' $@in }
edit:add-var ping~ { |@in| e:ping -c 5 $@in }
edit:add-var updatePip~ { pip install -U (pip freeze | each {|c| re:split "==| @" $c | cmds:first [(all)] }) }

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

# Print bound keys: `bound-keys $edit:insert:binding`
fn bound-keys {|binding| pprint $binding |
	each { |line|
		var @m = (re:find '^ &(.*?)=' $line)
		if (not (eq $m [])) {
			put $m[0][groups][1][text]
}	}	}
edit:add-var bound-keys~ $bound-keys~

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

#===================================================Transfer a file (using either transfer.sh or 0x0.st)
fn transfer {|@in &use=transfer| 
	var url = ''
	if (==s $use "transfer") { set url = (e:curl --upload-file $@in 'https://transfer.sh/'$@in) 
	} else { set url = (e:curl -F 'file=@'$@in 'https://0x0.st') }
	header1 "\n======================================================="
	md:show "The *online URL* for the file is: "$url
}
edit:add-var transfer~ $transfer~

#===================================================Cl1p service
fn cl1p {|in name|
	var key = (e:cat ~/.cl1papitoken)
	e:curl -H "Content-Type: text/html; charset=UTF-8" -H "cl1papitoken: "$key -X POST --data $in https://api.cl1p.net/$name
	md:show (echo "Read data using `curl https://api.cl1p.net/"$name"`")
}
edit:add-var cl1p~ $cl1p~

#===================================================Reset Vivaldi's PIP
fn resetPIP { 
	if ?(pgrep "Vivaldi" >/dev/null ) { echo (styled "\n!!!Warning: Vivaldi is running\n" bold red) }
	var vp = $E:HOME"/Library/Application Support/Vivaldi/Default/Preferences"
	msg "\n=== Reset Vivaldi's PIP ===\n"
	msg "\tCurrent Value:\n"
	jq '.vivaldi.pip_placement' $vp
	cp $vp $vp'.bak'
	jq '.vivaldi.pip_placement.top = 45 | .vivaldi.pip_placement.left = 20' $vp | sponge $vp
	echo (styled "\tNew Value:\n" bold yellow)
	jq '.vivaldi.pip_placement' $vp
}
edit:add-var resetPIP~ $resetPIP~

#===================================================Kill process listening on a port
fn killPort {|port &dry-run=$false|
	# Usage: killPort <port> [&dry-run=$true]
	if (not $port) { msg "Usage: killPort <port> [&dry-run=$true]" > /dev/stderr; return }
	# Get PID of process listening on the given port
	try {
		var pid = (lsof -i :$port -sTCP:LISTEN -t | head -n 1)
	} catch {
		msg "No process listening @ port:"$port; return
	}
	var pname = (ps -p $pid -o comm=) # Get process name
	# Dry-run behavior
	if (eq $dry-run $true) {
		msg "[DRY-RUN] Would kill process "$pname" (PID "$pid") listening on port "$port
	} else {
		msg "Killing process "$pname" (PID "$pid") listening on port "$port"..."
		e:kill $pid
	}
}
edit:add-var killPort~ $killPort~

#===================================================Setproxy [-x] [-l] [address]
fn sp {|@ina|
	use flag
	var @in = (flag:parse $ina [ [l $false "List proxies"] [x $false "Use XTLS"] [h $false "Get Help"]])
	var @plist = {http,https,ftp,all}_proxy
	fn unsetProxies {
		unset-env no_proxy
		each {|t| unset-env $t; unset-env (str:to-upper $t) } $plist
		try { git config --global --unset http.proxy } catch { }; try { git config --global --unset https.proxy } catch { }
	}
	fn listProxies {
		msg "PROXY: HTTP = "$E:http_proxy" | HTTPS = "$E:https_proxy" | ALL = "$E:all_proxy"\nBYPASS: "$E:no_proxy
		try { echo "GIT: "(git config --global --get-regexp http | slurp | str:replace "\n" " " (one)) } catch { }
	}
	fn parseAddress { |in|
		set in = (to-string $in)
		var protocol = 'http'; var addr = '127.0.0.1'; var port = '16005'
		var @tmp = (str:split "://" $in)
		if (== (count $tmp) 1) { set addr = $tmp[0] } elif (== (count $tmp) 2) { set protocol = $tmp[0]; set addr = $tmp[1] }
		var @tmp = (str:split ":" $addr)
		if (== (count $tmp) 2) { set addr = $tmp[0]; set port = $tmp[1] }
		put $protocol $addr $port
	}
	fn setenv { |&addr='127.0.0.1:16005'|
		set-env no_proxy "localhost, 127.0.0.1, ::1"
		each {|t| set-env $t $addr; set-env (str:to-upper $t) $addr } $plist
	}
	fn setgit { |&addr='127.0.0.1:16005' &xtls=$false| git config --global http.proxy $addr; git config --global https.proxy $addr }
	#===
	if $in[0][h] { 
		msg "sp Command Help:\n===============\n > sp 127.0.0.1:16005 to set proxy\n > sp without input to unset proxy\n … -l to list settings\n … -x uses XTLS mode"
	} elif $in[0][l] { 
		header1 "===========List proxy=========="
	} elif (eq $in[1] []) {
		header1 "==========Unset proxy============"
		unsetProxies
	} else {
		header1 "==========Set proxy============"
		var @r = (parseAddress $in[1][0])
		if (eq $r[0] $nil) { set r[0] = 'http' }; if (eq $r[2] $nil) { set r[2] = '16005' }
		var p = (num $r[2]); set p = (+ $p 1); set p = (to-string $p)
		if $in[0][x] {
			setenv &addr="http://"$r[1]":"$p; setgit &addr="socks5://"$r[1]":"$r[2] &xtls=$in[0][x]
		} else {
			setenv &addr=$r[0]"://"$r[1]":"$r[2]; setgit &addr=$r[0]"://"$r[1]":"$r[2] &xtls=$in[0][x]
		}
	}
	listProxies
}
edit:add-var sp~ $sp~
set edit:command-abbr['setproxy'] = 'sp'

#===================================================Install MATLAB
fn installMATLAB {|&version='R2025a' &action='install' &products='' &dest=''|
	var dest = ''
	var cmd = ''
	header1 "MATLAB Installation using MPM"
	cmds:if-external mpm {
			msg "mpm is already installed!"
	} { 
		msg "Install mpm"
		if ( cmds:is-macos ) { curl -L -o ~/bin/mpm https://www.mathworks.com/mpm/maca64/mpm } elif ( cmds:is-linux ) { curl -L -o ~/bin/mpm https://www.mathworks.com/mpm/glnxa64/mpm }
		chmod +x ~/bin/mpm
	}
	if (==s $products '') {
		set products = 'MATLAB Curve_Fitting_Toolbox Instrument_Control_Toolbox MATLAB_Report_Generator MATLAB_Compiler Optimization_Toolbox Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox'
	}
	if (==s $dest '') { 
		if ( cmds:is-macos ) { set dest = '/Applications/MATLAB/'$version } elif ( cmds:is-linux ) { set dest = '/usr/local/MATLAB/'$version }
	}
	set dest = $E:HOME"/tmp"
	if (==s $action 'install') { 
		set cmd = $E:HOME"/bin/mpm install --no-gpu --no-jre --release="$version" --destination="$dest" --products="$products
		msg "Install "$version" of MATLAB:\n\t"$cmd
		eval $cmd
	} elif (==s $action 'download') { 
		set cmd = $E:HOME"/bin/mpm download --release="$version" --destination="$E:HOME"/Downloads/matlab"$version" --products="$products
		msg "Download "$version" of MATLAB:\n\t"$cmd
		eval $cmd
	}
	msg "...Finished..."
}
edit:add-var installMATLAB~ $installMATLAB~

#========================================Install required TeX packages for BasicTex
# tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet
fn updateTeX {|&repo=tuna &ctex=$false|
	cmds:if-external tlmgr {
		header2 "=== UPDATE TeX ==="
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
		if $ctex { tlmgr install ctex }
	}
}
edit:add-var updateTeX~ $updateTeX~

#====================================================Update code and OS
fn update {
	sudo -Bv; msg "…Sudo priviledge obtained…"
	sp -l
	header1 "====>>> Start Update @ "(styled (date) bold)" <<<===="
	if (cmds:not-path $E:HOME"/.x-cmd.root") { curl https://get.x-cmd.com | sh -i }
	if (cmds:not-path $E:HOME"/.pixi") { curl -fsSL https://pixi.sh/install.sh | bash }
	var olddir = (pwd)
	var oldbranch = ''
	var ul = [~/.dotfiles ~/Code/opticka ~/Code/octicka ~/Code/Titta ~/Code/Pingpong ^
	~/Code/CageLab ~/Code/matmoteGO ~/Code/PTBSimia ~/Code/Notes ^
	~/Code/matlab-jzmq ~/Code/matlab-zmq ^
	~/Code/AfterImage ~/Code/equiluminance ~/Code/Pinna ~/Code/spikes ^
	~/Code/Psychtoolbox-3 ~/Code/fieldtrip ~/Code/Training ~/Code/Palamedes ^
	~/Code/Mymou ~/Documents/MATLAB/gramm ^
	~/Code/scrivomatic ~/Code/dotpandoc ~/Code/bookends-tools ~/Code/pandocomatic ^
	~/Code/gears ~/Code/paru ^
	/media/$E:USER/data/Code/octicka /media/$E:USER/data/Code/Psychtoolbox-3]
	for x $ul {
		if (not (cmds:is-path $x/.git)) { continue }
		tmp pwd = $x
		try { set oldbranch = (git branch --show-current) } catch { }
		var @branches = (git branch -l | each { |x| str:trim (str:trim-space $x) '* ' })
		try { timeout 10s git fetch -t -q --all 2>$path:dev-null } catch { echo "\t…couldn't fetch!" }
		for y $branches {
			if (re:match '^(dev|main|master|umaster)' $y) {
				header2 "--->>> Updating "(styled $x bold)":"$y"…"
				try {
					git checkout -q $y 2>$path:dev-null
					var changes = (git status --porcelain | slurp)
					var stashed = $false
					if (not (eq $changes '')) {
						msg "	…local changes detected, stashing…"
						git stash
						set stashed = $true
					}
					timeout 60s git pull --ff-only -v
					if $stashed {
						msg "	…unstashing changes…"
						try { git stash pop } catch {
							msg "	…couldn't pop stash, please resolve manually."
						}
					}
				} catch {
					msg "	…couldn't pull!"
				}
			}
		}
		git remote -v
		if (re:match 'upstream' (git remote | slurp)) {
			msg "------> Fetching upstream…  "
			try { git fetch -v upstream } catch { msg "  …couldn't fetch upstream!" }
		}
		try { git checkout -q $oldbranch 2>$path:dev-null } catch { }
	}
	cd $olddir
	cmds:if-external brew {
		header2 "---> Updating BREW…"
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		try {
			brew update; brew outdated
			brew upgrade --no-quarantine --display-times
			brew cleanup --prune=all
		} catch { msg "\t\t …can't upgrade!" }
	}
	if (cmds:is-macos) { try { header2 "---> Check macOS updates…"; softwareupdate --list } catch { } }
	if (cmds:is-linux) {
		try { 
			header2 "---> Updating APT…"
			sudo apt update; sudo apt autoremove -y; apt list --upgradable
		} catch { msg "\t…couldn't update APT!"	}
		header2 "---> Updating snap/flatpak/firmware…"
		cmds:if-external snap { try { msg "\tsnap…"; sudo snap refresh } catch { } }
		cmds:if-external flatpak { try { msg "\tflatpak…"; flatpak update -y } catch { } }
		cmds:if-external fwupdmgr { try { msg "\tfirmware…"; fwupdmgr get-upgrades } catch { } }
	}

	# update cogmoteGO
	try { curl -sS https://raw.githubusercontent.com/Ccccraz/cogmoteGO/main/install.sh | sh } catch { }

	# update other tools
	cmds:if-external pixi { header2 "---> Update pixi"; pixi self-update; pixi global sync; pixi global -v update }
	cmds:if-external ya { header2 "---> Update Yazi"; ya pkg upgrade }
	cmds:if-external pkgx { header2 "---> Update pkgx"; pkgx --sync; pkgx --update }
	cmds:if-external micromamba { header2 "---> Update Micromamba…"; micromamba self-update }
	cmds:if-external gem { header2 "---> Update Ruby Gems"; gem update; gem cleanup }
	cmds:if-external rbenv { header2 "---> Rehash RBENV…"; rbenv rehash }
	cmds:if-external pyenv { header2 "---> Rehash PYENV…"; pyenv rehash }
	cmds:if-external tlmgr { header2 "---> Check TeX-Live…"; tlmgr update --self; tlmgr update --all }
	cmds:if-external npm { header2 "---> Update npm global"; npm list -g; npm update -g; npm list -g }
	cmds:if-external nvim { header2 "---> Update NVIM plugins…"; nvim --headless "+Lazy! sync" +qa }
	
	try { header2 "---> Updating Elvish Packages…";epm:upgrade } catch { echo "Couldn't update EPM packages…" }
	try { cmds:if-external x-cmd { header2 "---> Update 文 x-cmd"; x-cmd upgrade; x-cmd update; x-cmd env upgrade --all --force; x-cmd elv --setup mod } } catch { }
	header1 "====>>> Finish Update @ "(styled (date) bold)" <<<===="
}
edit:add-var update~ $update~

#====================================================UPDATE UBLOCK
fn updateuBlock {
	var @uSrc = (curl -s https://api.github.com/repos/gorhill/uBlock/releases | jq -r 'map(select(.prerelease)) | sort_by(.published_at) | last | .assets[]' | from-json)
	each { |rel| 
		if (cmds:is-match $rel[name] "chromium.zip$") {
			var url = $rel[browser_download_url]
			echo (styled "\n=== GET uBLOCK "$rel[name]" ===\nURL: "$url bold yellow)
			try {
				curl -k -L -o ublock.zip $url
				rm -rf $E:HOME/Downloads/uBlock0.chromium
				unzip -oq ublock.zip -d $E:HOME/Downloads/
				rm ublock.zip
			} catch { echo "Can't download uBlock!" }
		}
	} $uSrc
}
edit:add-var updateuBlock~ $updateuBlock~

#====================================================UPDATE MPV
fn updateMPV {
	if (!=s $platform:os 'darwin') { return }
	var mpvPath = '/Applications/mpv.app/Contents/MacOS/mpv'
	var oldver newver = '' ''
	cmds:if-external $mpvPath { set oldver = ($mpvPath --version | slurp) }
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	var mpvURL = 'https://nightly.link/mpv-player/mpv/workflows/build/master/mpv-macos-15-arm.zip'
	echo (styled "\n=== GET MPV ===\nURL: "$mpvURL bold yellow)
	try { wget --no-check-certificate -O mpv.zip $mpvURL
		unzip -p mpv.zip | tar -xf -
		sudo rm -rf /Applications/mpv.app
		sudo mv -vf mpv.app /Applications/mpv.app
		cmds:if-external $mpvPath { 
			set newver = ($mpvPath --version | slurp) 
			echo (styled "===UPDATED:===\nOld: "$oldver"\nNew: "$newver"\n" bold yellow)
		} } catch { msg "Can't download MPV!" }
	cd $olddir
	rm -rf $tmpdir
}
edit:add-var updateMPV~ $updateMPV~

#====================================================UPDATE XRAY
fn updateXRay {
	if (!=s $platform:os 'linux') { return }
	echo (styled "\n=== UPDATE XRAY & V2RAYA ===\n" bold yellow)
	var xLabel = ''; var vLabel = ''
	if (and (cmds:is-mac) (cmds:is-arm64)) {
		var xLabel = "Xray-macos-arm64-v8a.zip$"
		var vLabel = "v2raya_darwin_arm"
	} elif (and (cmds:is-linux) (cmds:is-arm64)) {
		var xLabel = "Xray-linux-64.zip$"
		var vLabel = "debian_x64.+deb$"
	} elif (cmds:is-linux) {
		set xLabel = "Xray-linux-arm64-v8a.zip$"
		set vLabel = "debian_arm64.+deb$"
	} else { return }
	var xSrc = ''; var vSrc = ''; var cSrc = ''
	var xURL = ''; var vURL = ''; var clURL = ''
	try {
		set xSrc = (curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | from-json)
		set vSrc = (curl -s https://api.github.com/repos/v2raya/v2raya/releases/latest | from-json)
		set cSrc = (curl -s https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest | from-json)
	} catch {
		echo (styled "Failed to get Repo info!\n" bold red)
		break
	}
	cmds:if-external xray {
		echo "XRay remote: "$xSrc[name]" | local: "(xray --version | sd -f s '(Xray )([\d\.]+) (.+)' '$2')
		} { echo "XRay remote: "$xSrc[name] }
	cmds:if-external v2raya {
		echo "V2RayA remote: "$vSrc[name]" | local: "(v2raya --version)
	} { echo "V2RayA remote: "$vSrc[name] }
	if (cmds:is-path '/Applications/clash Verge.app/') {
		echo "Clash remote: "$cSrc[name]" | local: "(defaults read '/Applications/clash Verge.app/Contents/Info.plist' CFBundleShortVersionString)
	} else { echo "Clash remote: "$cSrc[name] }

	each {|a| 
		if (re:match $xLabel $a[browser_download_url]) { set xURL = $a[browser_download_url] }
	} $xSrc[assets]
	if (!=s $xURL '') {
		echo (styled "\n=== GET XRAY ===\nURL: "$xURL bold yellow)
		try { wget --no-check-certificate -O xray.zip $xURL
			sudo unzip -o xray.zip -d /usr/local/bin
		} catch { echo "Can't download Xray!" }
	}

	each {|a| 
		if (re:match $vLabel $a[browser_download_url]) { set vURL = $a[browser_download_url] }
	} $vSrc[assets]
	if (!=s $vURL '') {
		echo (styled "\n=== GET V2RAYA ===\nURL: "$vURL bold yellow)
		try { wget --no-check-certificate -O v2raya.deb $vURL
			if cmds:is-linux { sudo dpkg -i v2raya.deb }
		} catch { echo "Can't download V2raya!" }
	}
}
edit:add-var updateXRay~ $updateXRay~

#===================================================Update Elvish
fn updateElvish {|&source=tuna|
	var url = 'https://mirrors.tuna.tsinghua.edu.cn/elvish/'$platform:os'-'$platform:arch'/elvish-HEAD.tar.gz'
	if (!=s $source 'tuna') { set url = 'https://dl.elv.sh/'$platform:os'-'$platform:arch'/elvish-HEAD.tar.gz' }
	var oldver newver = '' ''
	cmds:if-external elvish { set oldver = (elvish -version) }
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
		cmds:if-external elvish { 
			set newver = (elvish -version)
			echo (styled "===UPDATED:===\nOld: "$oldver"\nNew: "$newver"\n" bold yellow)
		}
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}
edit:add-var updateElvish~ $updateElvish~

#===================================================Update FFMPEG
fn updateFFmpeg {
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	var oldver newver  = '' ''
	var os = $platform:os
	if (eq $os 'darwin') { set os = 'macos'}
	cmds:if-external ffmpeg { set oldver = (ffmpeg -version | grep -owE 'ffmpeg version [^ :]+' | sed -E 's/ffmpeg version//g') }
	echo (styled "\n===FFMPEG UPDATE===\nOS: "$os" & Arch: "$platform:arch bold yellow)
	var tnames = [ffmpeg ffplay ffprobe]
	for x $tnames {
		try {
			wget --no-check-certificate -O $x.zip 'https://ffmpeg.martin-riedl.de/redirect/latest/'$os'/'$platform:arch'/snapshot/'$x'.zip'
			unzip -o $x.zip -d /usr/local/bin/
		} catch { echo "Can't download "$x }
	}
	cmds:if-external ffmpeg { set newver = (ffmpeg -version | grep -owE 'ffmpeg version [^ :]+' | sed -E 's/ffmpeg version//g') }
	echo (styled "===UPDATED:===\nOld: "$oldver"\nNew: "$newver"\n" bold yellow)
	cd $olddir
	rm -rf $tmpdir
}
edit:add-var updateFFmpeg~ $updateFFmpeg~

#===================================================Update Opticka
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

#===================================================Update everything
fn updateAll {
	update
	if (cmds:is-linux) { sudo apt full-upgrade -y }
	updateuBlock
	updateMPV
	updateElvish
	updateFFmpeg
	updateTeX
}
edit:add-var updateAll~ $updateAll~
