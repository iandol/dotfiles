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
set edit:command-abbr['rs'] = 'rsync -ahv --progress --itemize-changes --delete'
set edit:command-abbr['cd'] = 'z' #switch to zoxide
set edit:command-abbr['lz'] = 'lazygit' #git tui
set edit:command-abbr['curld'] = 'curl --retry 5 -L -C -'
set edit:command-abbr['xp'] = 'x proxy set 127.0.0.1:'
set edit:command-abbr['xpu'] = 'x proxy unset'
set edit:command-abbr['sds'] = 'sudo -E systemctl st'
set edit:command-abbr['sdu'] = 'systemctl --user st'
set edit:command-abbr['ju'] = 'journalctl --user --all -f -u'
set edit:command-abbr['js'] = 'journalctl --all -f -u'
set edit:command-abbr['edit'] = 'nvim'
set edit:command-abbr['arch'] = 'arch -x86_64'
# set edit:abbr['sudo '] = 'sudo -- '
# set edit:small-word-abbr['ll'] = 'ls -alFGh@'
# set edit:small-word-abbr['ls'] = 'ls -GF'

#==================================================== - BUGFIX
edit:add-var runMATLAB~ {
	echo "Xft.dpi: 96" > ~/.Xres; xrdb -merge ~/.Xres
	sleep 1
	matlab &
	sleep 10
	echo "Xft.dpi: 150" > ~/.Xres; xrdb -merge ~/.Xres }

#==================================================== - ELVISH
edit:add-var za~ {|prefix start end suffix| put "("(print $prefix(range $start $end)$suffix)")" } #zsh array as a string
edit:add-var ssh-agent-setup~ {
	if (has-env SSH_AUTH_SOCK) { msg "Agent already running"; return }
	try {
		var output = (ssh-agent -s | slurp)
		set-env SSH_AUTH_SOCK (re:find 'SSH_AUTH_SOCK=([^;]+);' $output)[groups][1][text]
		set-env SSH_AGENT_PID (re:find 'SSH_AGENT_PID=([^;]+);' $output)[groups][1][text]
		msg "SSH agent with PID "$E:SSH_AGENT_PID" configured..."
	} catch { msg "Problem setting up SSH agent!" }
}
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
edit:add-var kittymap~ { bat ~/.config/kitty/kitty.map | fzf --ansi --style full }
cmds:if-external kitty {
	edit:add-var kittydef~ {  kitty +runpy 'from kitty.config import *; print(commented_out_default_config())' > $E:HOME/.dotfiles/terminals/kitty/kitty-default.conf }
	edit:add-var kssh~ { |@in| kitten ssh $@in --kitten login_shell=elvish }
	edit:add-var ksshz~ { |@in| kitten ssh $@in --kitten login_shell=zsh }
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

#==================================================== - Management
fn sshTab { |@hostname &tool=tssh|
	# This function opens a new kitty tab and SSH into the given hostname.
	# It works on both macOS and Linux systems.
	#
	# https://sw.kovidgoyal.net/kitty/remote-control/#kitten-launch
	#
	# Usage: sshTab <hostname>
	# Example: sshTab my-server.com
	each { |h|
		if ( ==s $tool 'mosh' )	{
			put "Opening MOSH tab to "$h
			cmds:if-external kitty {
				kitten @ launch --type tab --tab-title $h -- (which mosh) $h
			} { mosh $h }
		} elif ( ==s $tool 'tssh' )	{
			put "Opening TSSH tab to "$h
			cmds:if-external kitty {
				kitten @ launch --type tab --tab-title $h -- (which tssh) $h
			} { tssh $hostname[0] }
		} else {
			put "Opening SSH tab to "$h
			cmds:if-external kitty {
				kitten @ launch --type tab --tab-title $h kitten ssh $h --kitten login_shell=elvish
			} { ssh $hostname[0] }
		}
	} $@hostname
}
edit:add-var sshTab~ $sshTab~

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
edit:add-var cagelab-zsh~ { ln -svf $E:HOME/Code/Setup/config/zshrc $E:HOME/.zshrc; ln -svf $E:HOME/Code/Setup/config/zsh-* $E:HOME/.config; ln -svf $E:HOME/Code/Setup/config/aliases $E:HOME/.config }

#==================================================== - GENERAL
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
		open -a LaunchControl.app
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
}

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
edit:add-var installmicromamba~ { curl -L micro.mamba.pm/install.sh | zsh /dev/stdin }

#==================================================== - CHECK APPS ALIASES
cmds:if-external httping { edit:add-var hping~ {|@in| e:httping -K $@in } }
cmds:if-external bat { edit:add-var cat~ {|@in| e:bat $@in } }
cmds:if-external python3 { 
	edit:add-var urlencode~ { |@in| e:python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));" $@in } 
	edit:add-var urldecode~ { |@in| e:python3 -c "import sys, urllib.parse as ul; print(ul.unquote(sys.argv[1]));" $@in } 
}
cmds:if-external nvim { edit:add-var vi~ $e:nvim~ }

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


#==================================================== - TOGGLE NVIM
fn nvimToggle { 
  if (cmds:is-path ~/.config/nvim.ian) {
    mv ~/.config/nvim{,.lazy}; mv ~/.local/state/nvim{,.lazy}; mv ~/.local/share/nvim{,.lazy}
    mv ~/.config/nvim{.ian,}; mv ~/.local/state/nvim{.ian,}; mv ~/.local/share/nvim{.ian,}
  } elif (cmds:is-path ~/.config/nvim.lazy) {
    mv ~/.config/nvim{,.ian}; mv ~/.local/state/nvim{,.ian}; mv ~/.local/share/nvim{,.ian}
    mv ~/.config/nvim{.lazy,}; mv ~/.local/state/nvim{.lazy,}; mv ~/.local/share/nvim{.lazy,}
  }
}
edit:add-var nvimToggle~ $nvimToggle~

#===================================================Transfer a file
# Upload files and print their public URL.
#   transfer shot.png                 # uguu.se: direct GET link, kept ~3 hours
#   transfer log.txt &use=temp.sh     # temp.sh: download page, kept ~3 days
# The old backends are gone: transfer.sh was retired in 2024 and 0x0.st has
# uploads disabled, so neither can work any more.
fn transfer {|@in &use=uguu|
	if (== (count $in) 0) {
		msg "transfer — upload files and print their public URLs"
		echo '  usage: transfer <file> [<file> …] [&use=uguu|temp.sh]'
		echo '    uguu     https://uguu.se    direct link, works with curl, kept ~3 hours'
		echo '    temp.sh                     download page, kept ~3 days'
		echo '  retired: transfer.sh (shut down 2024) · 0x0.st (uploads disabled)'
		return
	}
	if (or (==s $use 'transfer') (==s $use '0x0')) {
		msg (styled "…"$use" no longer works — transfer.sh retired, 0x0.st disabled uploads; use &use=uguu or temp.sh" bold red)
		return
	} elif (and (!=s $use 'uguu') (!=s $use 'temp.sh')) {
		msg (styled "…unknown backend "$use" — use uguu or temp.sh" bold red)
		return
	}
	each {|f|
		if (not (path:is-regular $f)) {
			msg (styled "…not a file: "$f bold red)
		} else {
			header1 "TRANSFER "$f" → "$use
			var url = ''
			try {
				if (==s $use 'uguu') {
					set url = (e:curl -sS --max-time 300 -F 'files[]=@'$f 'https://uguu.se/upload?output=text')
				} else {
					set url = (e:curl -sS --max-time 300 -F 'file=@'$f 'https://temp.sh/upload')
				}
			} catch e {
				msg (styled "…upload failed: "(to-string $e) bold red)
			}
			if (re:match '^https?://' $url) {
				md:show "The *online URL* for the file is: "$url
			} elif (not-eq $url '') {
				msg (styled "…unexpected answer from "$use": "$url bold red)
			}
		}
	} $in
}
edit:add-var transfer~ $transfer~

#===================================================Cl1p service
# cl1p <content> <name> -- POST text to cl1p.net so it can be read back with
# `curl https://api.cl1p.net/<name>` or in a browser at https://cl1p.net/<name>.
# The API token is read from ~/.cl1papitoken.
fn cl1p {|@args|
	if (!= (count $args) 2) {
		msg "cl1p — share text through cl1p.net"
		echo '  usage: cl1p "the text to share" mynote'
		echo '         curl https://api.cl1p.net/mynote    # read it back'
		echo '         https://cl1p.net/mynote             # …or open it in a browser'
		echo '  token: ~/.cl1papitoken (sent as the cl1papitoken header)'
		return
	}
	if (not (path:is-regular ~/.cl1papitoken)) {
		msg (styled "…no API token at ~/.cl1papitoken — create one at cl1p.net first" bold red)
		return
	}
	var content = $args[0]
	var name = $args[1]
	var key = (e:cat ~/.cl1papitoken)
	e:curl -H "Content-Type: text/html; charset=UTF-8" -H "cl1papitoken: "$key -X POST --data $content https://api.cl1p.net/$name
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
		var protocol = 'http'; var addr = '127.0.0.1'; var port = '20171'
		var @tmp = (str:split "://" $in)
		if (== (count $tmp) 1) { set addr = $tmp[0] } elif (== (count $tmp) 2) { set protocol = $tmp[0]; set addr = $tmp[1] }
		var @tmp = (str:split ":" $addr)
		if (== (count $tmp) 2) { set addr = $tmp[0]; set port = $tmp[1] }
		put $protocol $addr $port
	}
	fn setenv { |&addr='127.0.0.1:20171'|
		set-env no_proxy "localhost, 127.0.0.1, ::1"
		each {|t| set-env $t $addr; set-env (str:to-upper $t) $addr } $plist
	}
	fn setgit { |&addr='127.0.0.1:16005' &xtls=$false| git config --global http.proxy $addr; git config --global https.proxy $addr }
	#===
	if $in[0][h] { 
		msg "sp Command Help:\n===============\n > sp 127.0.0.1:20171 to set proxy\n > sp without input to unset proxy\n … -l to list settings\n … -x uses XTLS mode"
	} elif $in[0][l] { 
		header1 "===========List proxy=========="
	} elif (eq $in[1] []) {
		header1 "==========Unset proxy============"
		unsetProxies
	} else {
		header1 "==========Set proxy============"
		var @r = (parseAddress $in[1][0])
		if (eq $r[0] $nil) { set r[0] = 'http' }; if (eq $r[2] $nil) { set r[2] = '20171' }
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

#===================================================Install/Update KITTY
fn installKitty {|&nightly=$false|
	if $nightly {
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin installer=nightly
	} else {
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	}
	if (cmds:is-linux) {
		ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
		cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
		cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
		sed -i "s|Icon=kitty|Icon=/home/"$E:USER"/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
		sed -i "s|Exec=kitty|Exec=/home/"$E:USER"/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
		echo "kitty.desktop" > ~/.config/xdg-terminals.list
	}
}
edit:add-var installKitty~ $installKitty~

#===================================================Install MATLAB
fn installMATLAB {|&version='R2025b' &action='install' &products='' &dest=''|
	var dest = ''
	var cmd = ''
	cmds:header1 "MATLAB Installation using MPM"
	cmds:if-external mpm {
			cmds:msg "mpm is already installed!"
	} { 
		cmds:msg "Install mpm"
		if ( cmds:is-macos ) { curl -L -o ~/bin/mpm https://www.mathworks.com/mpm/maca64/mpm } elif ( cmds:is-linux ) { curl -L -o ~/bin/mpm https://www.mathworks.com/mpm/glnxa64/mpm }
		chmod +x ~/bin/mpm
	}
	if (==s $products '') {
		set products = 'MATLAB Curve_Fitting_Toolbox Instrument_Control_Toolbox MATLAB_Report_Generator MATLAB_Compiler Optimization_Toolbox Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox'
	}
	if (==s $dest '') { 
		if ( cmds:is-macos ) { set dest = '/Applications/MATLAB/'$version } elif ( cmds:is-linux ) { set dest = '/usr/local/MATLAB/'$version }
	}
	set dest = "/usr/local/MATLAB/"$version
	if (==s $action 'install') { 
		set cmd = $E:HOME"/bin/mpm install --no-gpu --no-jre --release="$version" --destination="$dest" --products="$products
		cmds:msg "Install "$version" of MATLAB:\n\t"$cmd
		eval $cmd
	} elif (==s $action 'download') { 
		set cmd = $E:HOME"/bin/mpm download --release="$version" --destination="$E:HOME"/Downloads/matlab"$version" --products="$products
		cmds:msg "Download "$version" of MATLAB:\n\t"$cmd
		eval $cmd
	}
	cmds:msg "...Finished..."
}
edit:add-var installMATLAB~ $installMATLAB~

#====================================================Update code and OS
fn update {
	sudo -Bv; msg "…Sudo priviledge obtained…"
	sp -l
	header1 "====>>> Start Update @ "(styled (date) bold)" <<<===="
	if (cmds:not-path $E:HOME"/.x-cmd.root") { curl https://get.x-cmd.com | sh -i }
	if (cmds:not-path $E:HOME"/.pixi") { curl -fsSL https://pixi.sh/install.sh | bash }
	var olddir = (pwd)
	var oldbranch = ''
	var ul = [ ^
		~/.dotfiles ~/Code/opticka ~/Code/CageLab-Code ~/Code/Setup ^
		~/Code/matmoteGO ~/Code/PTBSimia ~/Code/Notes ^
		~/Code/matlab-jzmq ~/Code/matlab-zmq ^
		~/Code/octicka ~/Code/Titta ~/Code/Pingpong ^
		~/Code/AfterImage ~/Code/equiluminance ~/Code/Pinna ~/Code/spikes ^
		~/Code/Psychtoolbox-3 ~/Code/fieldtrip ~/Code/Training ~/Code/Palamedes ^
		~/Code/Mymou ~/Documents/MATLAB/gramm ^
		~/Code/scrivomatic ~/Code/dotpandoc ~/Code/bookends-tools ~/Code/pandocomatic ^
		~/Code/gears ~/Code/paru ^
		/media/$E:USER/data/Code/octicka /media/$E:USER/data/Code/Psychtoolbox-3]
	for x $ul {
		if (not (cmds:is-path $x/.git)) { continue }
		header2 "Git: Checking "$x
		tmp pwd = $x
		try { set oldbranch = (git branch --show-current) } catch { }
		var @branches = (git branch -l | each { |x| str:trim (str:trim-space $x) '* ' })
		try { timeout 10s git fetch -t -q --all 2>$path:dev-null } catch { echo "\t…couldn't fetch!" }
		
		# Stash changes before working with branches
		var changes = (git status --porcelain | slurp)
		var stashed = $false
		if (not (eq $changes '')) {
			msg "	…local changes detected, stashing…"
			try { 
				git stash push -u -m "Auto-stash before update on "(date)
				set stashed = $true
			} catch {
				msg "	…couldn't stash changes!"
			}
		}
		
		for y $branches {
			if (re:match '^(dev|main|master|umaster)' $y) {
				msg "--->>> Updating "(styled $x bold)":"$y"…"
				try {
					git checkout -q $y 2>$path:dev-null
					timeout 60s git pull --ff-only -v
				} catch {
					msg "	…couldn't pull!"
				}
			}
		}
		git remote -v
		if (re:match 'upstream' (git remote | slurp)) {
			msg "--->>> Fetching upstream…  "
			try { git fetch -v upstream } catch { msg "  …couldn't fetch upstream!" }
		}
		try { git checkout -q $oldbranch 2>$path:dev-null } catch { }
		
		# Unstash changes after returning to original branch
		if $stashed {
			msg "	…unstashing changes…"
			try { 
				git stash pop 
			} catch {
				msg "	…couldn't pop stash, please resolve manually."
			}
		}
	}
	cd $olddir
	cmds:if-external brew {
		header2 "Updating BREW…"
		set-env HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 'true'
		try {
			brew update; brew outdated
			brew upgrade --yes --display-times
			brew cleanup --prune=2
		} catch { msg "\t\t …can't upgrade!" }
	}
	if (cmds:is-macos) { try { header2 "Check macOS updates…"; softwareupdate --list } catch { } }
	if (cmds:is-linux) {
		try { 
			header2 "Updating APT…"
			sudo apt update; sudo apt autoremove -y; apt list --upgradable
		} catch { msg "\t…couldn't update APT!"	}
		header2 "Updating snap/flatpak/firmware…"
		cmds:if-external snap { try { msg "\tsnap…"; sudo snap refresh } catch { } }
		cmds:if-external flatpak { try { msg "\tflatpak…"; flatpak update -y } catch { } }
		cmds:if-external fwupdmgr { try { msg "\tfirmware…"; fwupdmgr get-upgrades } catch { } }
	}

	# update cogmoteGO
	try { curl -sS https://raw.githubusercontent.com/cagelab/cogmoteGO/main/install.sh | sh } catch { }

	# update other tools
	cmds:if-external pixi { header2 "Update pixi"; pixi self-update; pixi global sync; pixi global -v update }	
	cmds:if-external nvim { header2 "Update NVIM plugins…"; nvim --headless "+Lazy! sync" +qa }
	cmds:if-external ya { header2 "Update Yazi"; ya pkg upgrade --discard }
	cmds:if-external eget { header2 "Update eget"; eget zyedidia/eget --upgrade-only }
 
	try { header2 "Updating Elvish Packages…";epm:upgrade } catch { echo "Couldn't update EPM packages…" }
	try { cmds:if-external x-cmd { header2 "Update 文 x-cmd"; x-cmd upgrade; x-cmd update; x-cmd env upgrade --all --force; x-cmd elv --setup mod } } catch { }
	header1 "====>>> Finish Update @ "(styled (date) bold)" <<<===="
}
edit:add-var update~ $update~

#====================================================UPDATE UBLOCK
# uBlock publishes its Chromium dev build as a *prerelease*, and the releases
# endpoint returns newest-first, so the first prerelease *is* the current one —
# the old `jq 'sort_by(.published_at) | last'` was computing exactly that.
#   updateuBlock                 # download + unpack into ~/Downloads
#   updateuBlock &check=$true    # report the current release and asset only
fn updateuBlock {|&check=$false|
	var rels = (cmds:gh-api 'repos/gorhill/uBlock/releases?per_page=30')
	if (== (count $rels) 0) { msg (styled "…can't read the uBlock release metadata (gh/API unavailable)" bold red); return }
	var rel = []
	each {|r|
		if (and (eq $rel []) (has-key $r prerelease) (eq $r[prerelease] $true)) { set rel = $r }
	} $rels
	if (eq $rel []) { msg (styled "…no uBlock prerelease in the last 30 releases" bold red); return }
	var url = (cmds:asset-url $rel 'chromium[.]zip$')
	if (==s $url '') { msg (styled "…no chromium.zip asset in "$rel[tag_name] bold red); return }
	header2 "uBlock "$rel[tag_name]" ("(to-string $rel[published_at])")"
	msg "URL: "$url
	if $check { return }
	var dest = $E:HOME'/Downloads'
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	try {
		try {
			wget -q --no-check-certificate -O ublock.zip $url
			rm -rf $dest'/uBlock0.chromium'
			unzip -oq ublock.zip -d $dest
			echo (styled "===UPDATED: uBlock "$rel[tag_name] bold yellow)
			echo "unpacked into "$dest'/uBlock0.chromium'
		} catch e {
			msg (styled "…Can't install uBlock: "(to-string $e) bold red)
		}
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}
edit:add-var updateuBlock~ $updateuBlock~

#====================================================UPDATE MPV
# The macOS nightly is a GitHub Actions artifact whose name embeds the build:
#   mpv-v0.42.0-dev-gfe753a782-43295607237-macos-26-arm
# so the old fixed nightly.link URL (…/master/mpv-macos-26-arm.zip) answers 404
# forever. The current name is resolved from the Actions API (gh, else curl) and,
# failing that, from the nightly.link index page; the download still goes through
# nightly.link, so no GitHub login is needed. The artifact zip holds a single
# mpv.tar.gz that unpacks to mpv.app.
#   updateMPV                 # install only when the build differs
#   updateMPV &check=$true    # report local vs remote, change nothing
#   updateMPV &force=$true    # reinstall even if the build matches
#   updateMPV &arch=intel     # take a macos-…-intel build (default: arm64)
fn updateMPV {|&check=$false &force=$false &arch=''|
	if (!=s $platform:os 'darwin') { return }
	header2 "UPDATE MPV"
	var host = 'mpv-player/mpv'
	var wf = 'build'
	var branch = 'master'
	var want = $arch
	if (==s $want '') {
		if (==s $platform:arch 'amd64') { set want = 'intel' } else { set want = 'arm' }
	}
	# --- which artifact did the latest successful master build publish? ---
	var names = []
	var run = (cmds:gh-api 'repos/'$host'/actions/workflows/'$wf'.yml/runs?branch='$branch'&status=success&per_page=1')
	if (has-key $run workflow_runs) {
		if (> (count $run[workflow_runs]) 0) {
			var rid = (to-string $run[workflow_runs][0][id])
			var arts = (cmds:gh-api 'repos/'$host'/actions/runs/'$rid'/artifacts')
			if (has-key $arts artifacts) {
				each {|a| set names = (conj $names $a[name]) } $arts[artifacts]
			}
		}
	}
	if (== (count $names) 0) {
		# fallback: the nightly.link index lists the current names, no API quota
		var page = ''
		try { set page = (curl -fsSL --max-time 30 'https://nightly.link/'$host'/workflows/'$wf'/'$branch | slurp) } catch { }
		var @ms = (re:find 'mpv-[^"<>/ ]*?-macos-[0-9]+-'$want'[.]zip' $page)
		each {|m|
			set names = (conj $names (re:replace '[.]zip$' '' $m[text]))
		} $ms
	}
	# prefer the macos-26 build, then macos-15, then whatever remains
	var pick = ''
	var score = 0
	each {|n|
		var @m = (re:find '-macos-([0-9]+)-'$want'$' $n)
		if (not-eq $m []) {
			var v = (num $m[0][groups][1][text])
			var s = 1
			if (== $v 26) { set s = 3 } elif (== $v 15) { set s = 2 }
			if (> $s $score) { set score = $s; set pick = $n }
		}
	} $names
	if (==s $pick '') { msg (styled "…no mpv -macos-*-"$want" artifact in the latest build" bold red); return }
	var ver = ''
	var @vm = (re:find '^mpv-(.+)-[0-9]+-macos-[0-9]+-'$want'$' $pick)
	if (not-eq $vm []) { set ver = $vm[0][groups][1][text] }
	var url = 'https://nightly.link/'$host'/workflows/'$wf'/'$branch'/'$pick'.zip'
	# --- local version ---
	var bin = '/Applications/mpv.app/Contents/MacOS/mpv'
	var local = ''
	cmds:if-external $bin {
		try {
			var @lm = (re:find '^mpv ([^ ]+)' ($bin --version | head -n 1))
			if (not-eq $lm []) { set local = $lm[0][groups][1][text] }
		} catch { }
	}
	echo "remote: "$pick
	if (==s $local '') { echo "local : not installed" } else { echo "local : "$local }
	var same = (and (not-eq $ver '') (==s $ver $local))
	if $same { echo (styled "✔ up to date — the installed mpv is that build" green) } else { echo (styled "⬆ newer build available" bold magenta) }
	if (or $check (and $same (not $force))) { return }
	# --- download, unpack, install ---
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	try {
		header2 "GET "$url
		try {
			wget -q --no-check-certificate -O mpv.zip $url
			var sz = (os:stat ./mpv.zip)[size]
			if (< $sz 1000000) { fail "downloaded only "(to-string $sz)" bytes — not an artifact" }
			msg "downloaded "(to-string $sz)" bytes"
			unzip -p mpv.zip | tar xzf -
			if (not (path:is-dir ./mpv.app)) { fail "no mpv.app in the archive" }
			sudo rm -rf /Applications/mpv.app
			sudo mv -vf ./mpv.app /Applications/mpv.app
			var newver = ''
			cmds:if-external $bin {
				try {
					var @nm = (re:find '^mpv ([^ ]+)' ($bin --version | head -n 1))
					if (not-eq $nm []) { set newver = $nm[0][groups][1][text] }
				} catch { }
			}
			echo (styled "===UPDATED:===\nOld: "$local"\nNew: "$newver"\n" bold yellow)
		} catch e {
			msg (styled "…MPV update failed: "(to-string $e) bold red)
		}
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}
edit:add-var updateMPV~ $updateMPV~

#====================================================UPDATE XRAY
# Asset names differ per platform (XTLS/Xray-core · v2raya/v2raya):
#   linux  amd64 → Xray-linux-64.zip            installer_debian_x64_<v>.deb
#   linux  arm64 → Xray-linux-arm64-v8a.zip     installer_debian_arm64_<v>.deb
#   macos  amd64 → Xray-macos-64.zip            v2raya_darwin_x64_<v>
#   macos  arm64 → Xray-macos-arm64-v8a.zip     v2raya_darwin_arm64_<v>
# Every asset has a checksum sidecar (.dgst for Xray, .sha256.txt for v2raya)
# that is verified before anything is installed. clash-verge ships its own
# dmg/AppImage installer, so it is only reported here.
#   updateXRay                 # install only when the release differs
#   updateXRay &check=$true    # report local vs remote, change nothing
#   updateXRay &force=$true    # reinstall the current release
fn updateXRay {|&check=$false &force=$false|
	header2 "UPDATE XRAY & V2RAYA"
	var dest = /usr/local/bin
	var arm = (cmds:is-arm64)
	var xPat = ''
	var vPat = ''
	var vKind = 'deb'
	if (cmds:is-linux) {
		if $arm {
			set xPat = '^Xray-linux-arm64-v8a[.]zip$'
			set vPat = '^installer_debian_arm64_.*[.]deb$'
		} else {
			set xPat = '^Xray-linux-64[.]zip$'
			set vPat = '^installer_debian_x64_.*[.]deb$'
		}
	} else {
		set vKind = 'bin'
		if $arm {
			set xPat = '^Xray-macos-arm64-v8a[.]zip$'
			set vPat = '^v2raya_darwin_arm64_'
		} else {
			set xPat = '^Xray-macos-64[.]zip$'
			set vPat = '^v2raya_darwin_x64_'
		}
	}
	# --- remote release metadata ---
	var xSrc = (cmds:gh-latest 'XTLS/Xray-core')
	if (==s $xSrc[tag_name] '') { msg (styled "…can't read the Xray release metadata (gh/API unavailable)" bold red); return }
	var vSrc = (cmds:gh-latest 'v2raya/v2raya')
	var xRemote = (str:trim-left $xSrc[tag_name] 'v')
	var vRemote = ''
	if (!=s $vSrc[tag_name] '') { set vRemote = (str:trim-left $vSrc[tag_name] 'v') }
	# --- local versions ---
	var xLocal = ''
	var vLocal = ''
	cmds:if-external xray { set xLocal = (cmds:first-version (xray --version | slurp)) }
	cmds:if-external v2raya { set vLocal = (cmds:first-version (v2raya --version | slurp)) }
	var xTxt = 'not installed'
	if (!=s $xLocal '') { set xTxt = $xLocal }
	echo "XRay   : remote "$xRemote" | local "$xTxt
	if (!=s $vRemote '') {
		var vTxt = 'not installed'
		if (!=s $vLocal '') { set vTxt = $vLocal }
		echo "V2RayA : remote "$vRemote" | local "$vTxt
	}
	# --- what needs installing? ---
	var xURL = (cmds:asset-url $xSrc $xPat)
	var vURL = ''
	if (!=s $vRemote '') { set vURL = (cmds:asset-url $vSrc $vPat) }
	var xDo = (or $force (!=s $xRemote $xLocal))
	var vDo = (and (!=s $vURL '') (or $force (!=s $vRemote $vLocal)))
	if (not $xDo) { echo (styled "xray "$xLocal" is already the current release" green) }
	if (and (not $vDo) (!=s $vRemote '')) { echo (styled "v2raya "$vLocal" is already the current release" green) }
	if (and $xDo (==s $xURL '')) { msg (styled "…no Xray asset matches "$xPat bold red) }
	if (and $vDo (==s $vURL '')) { msg (styled "…no v2raya asset matches "$vPat bold red) }
	if $check { return }
	# --- download, verify, install ---
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	try {
		if (and $xDo (!=s $xURL '')) {
			header2 "GET XRAY "$xRemote
			echo "URL: "$xURL
			try {
				wget -q --no-check-certificate -O xray.zip $xURL
				var want = (cmds:remote-sha $xURL'.dgst' &pattern='SHA2-256=[ ]*([0-9a-f]{64})')
				var got = (cmds:sha256 ./xray.zip)
				if (and (not-eq $want '') (!=s $got $want)) { fail "xray.zip sha256 mismatch (want "$want", got "$got")" }
				msg "xray.zip sha256 verified "(cmds:hash-short $got)
				sudo unzip -o xray.zip -d $dest xray geoip.dat geosite.dat
			} catch e {
				msg (styled "…Can't install Xray: "(to-string $e) bold red)
			}
		}
		if (and $vDo (!=s $vURL '')) {
			header2 "GET V2RAYA "$vRemote
			echo "URL: "$vURL
			var vFile = 'v2raya.deb'
			if (==s $vKind 'bin') { set vFile = 'v2raya' }
			try {
				wget -q --no-check-certificate -O $vFile $vURL
				var want = (cmds:remote-sha $vURL'.sha256.txt')
				var got = (cmds:sha256 './'$vFile)
				if (and (not-eq $want '') (!=s $got $want)) { fail $vFile" sha256 mismatch (want "$want", got "$got")" }
				msg $vFile" sha256 verified "(cmds:hash-short $got)
				if (==s $vKind 'deb') {
					sudo dpkg -i $vFile
				} else {
					chmod +x $vFile
					sudo mv -vf $vFile $dest'/v2raya'
				}
			} catch e {
				msg (styled "…Can't install v2raya: "(to-string $e) bold red)
			}
		}
		# --- report the result ---
		var xBin = $dest'/xray'
		var xNow = ''
		var vNow = ''
		if (path:is-regular $xBin) {
			try { set xNow = (cmds:first-version ($xBin -version | slurp)) } catch { }
		}
		cmds:if-external v2raya { set vNow = (cmds:first-version (v2raya --version | slurp)) }
		if (and $xDo (!=s $xNow '')) {
			echo (styled "===XRAY: "$xLocal" → "$xNow"===" bold yellow)
			if (!=s $xNow $xRemote) { msg (styled "⚠ "$xBin" reports "$xNow", expected "$xRemote bold red) }
		}
		if (and $vDo (!=s $vNow '')) { echo (styled "===V2RAYA: "$vLocal" → "$vNow"===" bold yellow) }
		# clash-verge has its own installer, so only report its release
		if (or (cmds:is-path '/Applications/clash Verge.app') (has-external clash-verge)) {
			var cSrc = (cmds:gh-latest 'clash-verge-rev/clash-verge-rev')
			if (!=s $cSrc[tag_name] '') { echo "Clash  : remote "$cSrc[tag_name] }
		}
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}
edit:add-var updateXRay~ $updateXRay~

#===================================================Update Elvish
# Elvish ships a per-platform HEAD tarball with sha256 sidecars, so the remote
# build can be identified *without* downloading the ~6MB archive:
#   <base>/elvish-HEAD.tar.gz            archive (extracts to ./elvish)
#   <base>/elvish-HEAD.sha256sum         sha256 of the binary  → version check
#   <base>/elvish-HEAD.tar.gz.sha256sum  sha256 of the archive → download check
# The archive's Last-Modified header is the UTC build time that is baked into
# `elvish -version` (0.22.0-dev.0.20250308121232-49937be09a7e), so it doubles as
# a human-readable "remote version". There is no JSON API: dl.elv.sh/INDEX only
# lists file names and is rewritten only when a build is published, and the
# GitHub API is rate limited and does not track HEAD builds.
#   updateElvish                        # probe mirror, install only if newer
#   updateElvish &check=$true           # report local vs remote, never install
#   updateElvish &force=$true           # reinstall even if byte-identical
#   updateElvish &version=v0.21.0       # pin a released version instead of HEAD
#   updateElvish &source=dl|tuna|<url>  # pick mirror (tuna falls back to dl)
fn updateElvish {|&source=tuna &version=HEAD &check=$false &force=$false|
	var osarch = $platform:os'-'$platform:arch
	var art = 'elvish-'$version'.tar.gz'
	var bases = []
	if (re:match '^https?://' $source) {
		set bases = [$source]
	} elif (==s $source 'dl') {
		set bases = ['https://dl.elv.sh/'$osarch]
	} else {
		# tuna is fast from CN but not always reachable; dl.elv.sh is upstream
		set bases = ['https://mirrors.tuna.tsinghua.edu.cn/elvish/'$osarch 'https://dl.elv.sh/'$osarch]
	}
	var bin = /usr/local/bin/elvish
	var installed = $false
	var oldver = ''; var oldsha = ''
	if (path:is-regular $bin) {
		set installed = $true
		try { set oldver = ($bin -version) } catch { }
		set oldsha = (cmds:sha256 $bin)
	}
	header2 "ELVISH "$version" · "$osarch
	if $installed {
		msg "installed: "$oldver" · sha256 "(cmds:hash-short $oldsha)
	} else {
		msg "installed: none ("$bin")"
	}
	# --- probe the mirrors: two tiny requests, no archive download ---
	var base = ''; var rlmt = ''; var rbin = ''
	for b $bases {
		var p = (cmds:http-probe $b'/'$art)
		var bh = (cmds:remote-sha $b'/elvish-'$version'.sha256sum')
		if (==s $p[lmt] '') { set p[lmt] = '?' }
		var pc = 'HTTP '$p[code]
		if (==s $p[code] '000') { set pc = 'HTTP 000 (unreachable)' }
		msg "probe: "$b" → "$pc" · built "$p[lmt]" · sha256 "(cmds:hash-short $bh)
		if (==s $p[code] '200') { set base = $b; set rlmt = $p[lmt]; set rbin = $bh; break }
	}
	if (==s $base '') { msg (styled "…no mirror served "$art" — aborting" bold red); return }
	if (not (re:match '^https://dl\.elv.sh/' $base)) {
		var up = (cmds:http-probe 'https://dl.elv.sh/'$osarch'/'$art)
		if (not-eq $up[lmt] '') { msg "upstream dl.elv.sh built "$up[lmt] }
	}
	# --- is that build what we already have? ---
	var same = $false
	if $installed {
		if (not-eq $rbin '') {
			set same = (==s $rbin $oldsha)
		} else {
			# no binary sidecar (released tags): fall back to the version string
			set same = (str:has-prefix $oldver (str:trim-left $version 'v'))
		}
	}
	if $same { msg (styled "✔ up to date — installed binary is byte-identical to the published build" green) } elif (==s $version 'HEAD') { msg (styled "⬆ newer build published "$rlmt" — update available" bold magenta) } else { msg (styled "≢ installed is not "$version" ("$rlmt") — update available" bold magenta) }
	if (or $check (and $same (not $force))) { return }
	# --- download, verify, install ---
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	try {
		var updated = $false
		var trybases = [$base]
		for b $bases { if (!=s $b $base) { set trybases = (conj $trybases $b) } }
		for b $trybases {
			if $updated { break }
			header2 "GET "$b'/'$art
			try {
				wget -q --no-check-certificate -O $art $b'/'$art
				var wantTar = (cmds:remote-sha $b'/'$art'.sha256sum')
				var gotTar = (cmds:sha256 './'$art)
				if (and (not-eq $wantTar '') (!=s $gotTar $wantTar)) { fail "archive sha256 mismatch (want "$wantTar", got "$gotTar")" }
				msg "archive sha256 verified "(cmds:hash-short $gotTar)
				tar xzf $art
				each {|c|
					if (and (path:is-regular $c) (not (path:is-regular ./elvish))) { mv -vf $c ./elvish }
				} [./elvish ./elvish-HEAD './elvish-'$version]
				if (not (path:is-regular ./elvish)) { fail "no elvish binary in the archive" }
				chmod +x ./elvish
				sudo mv -vf ./elvish $bin
				var newver = ''; var newsha = ''
				try { set newver = ($bin -version) } catch { }
				set newsha = (cmds:sha256 $bin)
				if (and (not-eq $rbin '') (!=s $newsha $rbin)) { msg (styled "⚠ installed binary does not match the published sha256!" bold red) }
				echo (styled "===UPDATED:===\nOld: "$oldver"\nNew: "$newver"\n" bold yellow)
				set updated = $true
			} catch e {
				msg (styled "…failed from "$b": "(to-string $e) bold red)
			}
		}
		if (not $updated) { msg "…ELVISH was not updated" }
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}
edit:add-var updateElvish~ $updateElvish~

#===================================================Update FFMPEG
# Static builds from ffmpeg.martin-riedl.de. The documented script URLs are
#   …/redirect/latest/<os>/<arch>/<channel>/<tool>.zip
# and answer 307 pointing at an immutable build directory that carries the
# build id:  …/download/linux/amd64/1789931100_9.0.2/ffmpeg.zip
# so the remote build is identified by one bodiless request instead of pulling
# ~100MB of zips; every file also has a .sha256 sidecar that is verified before
# anything is installed.
# Two quirks worth knowing: the /redirect/ endpoint answers 404 to a HEAD (the
# probe must be a GET with the body thrown away), and the binaries report a
# suffixed version (`9.0.2-https://www.martin-riedl.de`, snapshots report
# `<branch>.git-<url>`), so the build id is remembered in $dest/.ffmpeg-build
# and the -version string is only used as a fallback test.
#   updateFFmpeg                  # release channel (default)
#   updateFFmpeg &channel=snapshot
#   updateFFmpeg &check=$true     # report local vs remote, change nothing
#   updateFFmpeg &force=$true     # reinstall even if the build matches
fn updateFFmpeg {|&channel=release &check=$false &force=$false|
	var tools = [ffmpeg ffprobe ffplay]
	var os = $platform:os
	if (eq $os 'darwin') { set os = 'macos' }
	var arch = $platform:arch
	var dest = /usr/local/bin
	header2 "FFMPEG "$channel" · "$os"-"$arch
	# --- remote build id: one redirect, no payload ---
	var url = 'https://ffmpeg.martin-riedl.de/redirect/latest/'$os'/'$arch'/'$channel'/ffmpeg.zip'
	var target = ''
	try { set target = (curl -sS --max-time 30 -o /dev/null -w '%{redirect_url}' $url) } catch { }
	if (==s $target '') { msg (styled "…can't resolve "$url" — no "$channel" build for "$os"-"$arch"?" bold red); return }
	var @bm = (re:find '/download/[^/]+/[^/]+/([0-9]+)_([^/]+)/ffmpeg[.]zip$' $target)
	if (eq $bm []) { msg (styled "…unexpected redirect target: "$target bold red); return }
	var build = $bm[0][groups][1][text]'_'$bm[0][groups][2][text]
	var ver = $bm[0][groups][2][text]
	var dir = (re:replace 'ffmpeg[.]zip$' '' $target)
	# --- what is installed? ---
	var bin = $dest'/ffmpeg'
	var local = ''
	if (path:is-regular $bin) {
		try {
			var @lm = (re:find '^ffmpeg version ([^ ]+)' ($bin -version | head -n 1))
			if (not-eq $lm []) { set local = $lm[0][groups][1][text] }
		} catch { }
	}
	var marker = $dest'/.ffmpeg-build'
	var seen = ''
	if (path:is-regular $marker) {
		try {
			var @ml = (slurp < $marker)
			if (> (count $ml) 0) { set seen = (str:trim-space $ml[0]) }
		} catch { }
	}
	echo "remote: "$ver" (build "$build")"
	if (==s $local '') { echo "local : not installed" } else { echo "local : "$local }
	# --- already there? build id first, version string as a fallback ---
	var same = $false
	if (==s $seen $build) {
		set same = $true
	} elif (and (not-eq $local '') (str:has-prefix $local $ver)) {
		set same = $true
	}
	if $same { echo (styled "✔ up to date — installed build is "$build green) } else { echo (styled "⬆ newer build available" bold magenta) }
	if (or $check (and $same (not $force))) { return }
	# --- download, verify, install ---
	var olddir = $pwd
	var tmpdir = (path:temp-dir)
	cd $tmpdir
	try {
		var ok = 0
		each {|t|
			var zurl = $dir$t'.zip'
			header2 "GET "$t".zip"
			echo $zurl
			try {
				wget -q --no-check-certificate -O $t'.zip' $zurl
				var want = (cmds:remote-sha $zurl'.sha256')
				var got = (cmds:sha256 './'$t'.zip')
				if (and (not-eq $want '') (!=s $got $want)) { fail $t".zip sha256 mismatch (want "$want", got "$got")" }
				msg $t".zip sha256 verified "(cmds:hash-short $got)
				try { unzip -oq $t'.zip' -d $dest } catch e { sudo unzip -oq $t'.zip' -d $dest }
				set ok = (+ $ok 1)
			} catch e {
				msg (styled "…"$t" failed: "(to-string $e) bold red)
			}
		} $tools
		if (== $ok (count $tools)) {
			echo $build > ./ffmpeg-build.txt
			try { mv -f ./ffmpeg-build.txt $marker } catch e { sudo mv -f ./ffmpeg-build.txt $marker }
			var newver = ''
			try {
				var @nm = (re:find '^ffmpeg version ([^ ]+)' ($bin -version | head -n 1))
				if (not-eq $nm []) { set newver = $nm[0][groups][1][text] }
			} catch { }
			echo (styled "===UPDATED:===\nOld: "$local"\nNew: "$newver"\n" bold yellow)
		} else {
			msg (styled "…only "$ok" of "(to-string (count $tools))" tools were installed" bold red)
		}
	} finally {
		cd $olddir
		rm -rf $tmpdir
	}
}
edit:add-var updateFFmpeg~ $updateFFmpeg~

#========================================Install required TeX packages for BasicTex
# tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet
fn updateTeX {|&repo=tuna &ctex=$false|
	cmds:if-external tlmgr {
		header2 "UPDATE TeX"
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
	updateMPV
	updateElvish
	updateFFmpeg
	updateTeX
	updateuBlock
	cmds:if-external hermes { header2 "Upgrade Hermes"; hermes update --no-backup -y }
	cmds:if-external opencode { header2 "Upgrade opencode"; opencode upgrade }
	cmds:if-external codebase-memory-mcp { header2 "Upgrade codebase mcp"; codebase-memory-mcp update }
	cmds:if-external herdr { header2 "Upgrade Herdr"; herdr update }
	cmds:if-external pkgx { header2 "Update pkgx"; pkgx --sync; pkgx --update }
	cmds:if-external micromamba { header2 "Update Micromamba…"; micromamba self-update }
	cmds:if-external rbenv { header2 "Rehash RBENV…"; rbenv rehash }
	cmds:if-external pyenv { header2 "Rehash PYENV…"; pyenv rehash }
	cmds:if-external npm { header2 "Update npm global"; npm list -g; npm update -g; npm list -g }
	cmds:if-external uv { header2 "Update UV tools"; uv tool upgrade --all }
	cmds:if-external pipx { header2 "Update PIPX packages"; pipx upgrade-all }
	#cmds:if-external gem { header2 "Update Ruby Gems"; gem update; gem cleanup }
	try { header2 "egetAll"; egetAll } catch { }
	header1 "====>>> Finish UpdateAll @ "(styled (date) bold)" <<<===="
}
edit:add-var updateAll~ $updateAll~

