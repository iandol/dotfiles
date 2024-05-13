#!/usr/local/bin/elvish

use os
use github.com/iandol/elvish-modules/cmds

var ztrunning = ?(systemctl status zerotier-one | grep 'active (running)' >$os:dev-null 2>&1)
var sshrunning = ?(systemctl status sshd | grep 'active (running)' >$os:dev-null 2>&1)
var ztactive = ?(sudo zerotier-cli -j info | jq '.online' > $os:dev-null 2>&1)

if (cmds:is-ok $ztrunning) { 
	sudo systemctl --no-pager status zerotier-one
} else { 
	echo "Restarting Zerotier"
	sudo systemctl restart zerotier-one
}
if (cmds:is-ok $ztactive) { 
	echo (styled "\n\nZerotier Server is ONLINE!\n\n" bold green)
} else { 
	echo (styled "\n\nZerotier NOT OFFLINE :-(\n\n" bold red)
}
if (cmds:is-ok $sshrunning) { 
	sudo systemctl --no-pager status sshd 
} else { 
	echo "Restarting SSHD"
	sudo systemctl restart sshd
}