#!/usr/local/bin/elvish

use os
use github.com/iandol/elvish-modules/cmds

var ztrunning = ?(systemctl status zerotier-one | grep 'active (running)' >$os:dev-null 2>&1)
var sshrunning = ?(systemctl status sshd | grep 'active (running)' >$os:dev-null 2>&1)
var ztactive = ?(sudo zerotier-cli -j info | jq '.online' > $os:dev-null 2>&1)

if (cmds:is-ok $ztrunning) { 
	echo (styled "Zerotier Status:" bold green)
	sudo systemctl --no-pager status zerotier-one
} else { 
	echo (styled "Restarting Zerotier!" bold red)
	sudo systemctl restart zerotier-one
	sudo systemctl --no-pager status zerotier-one
}
if (cmds:is-ok $ztactive) { 
	echo (styled "\n\nZerotier Server is ONLINE!\n\n" bold green)
} else { 
	echo (styled "\n\nZerotier NOT OFFLINE :-(\n\n" bold red)
}
if (cmds:is-ok $sshrunning) { 
	echo (styled "SSHD Status:" bold green)
	sudo systemctl --no-pager status sshd
} else { 
	echo (styled "Restarting SSHD!" bold red)
	sudo systemctl restart sshd
	sudo systemctl --no-pager status sshd 
}