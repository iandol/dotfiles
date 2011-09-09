# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bira"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(osx ruby brew git rvm)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/Users/iana/.rvm/gems/ruby-1.9.2-p180/bin:/Users/iana/.rvm/gems/ruby-1.9.2-p180@global/bin:/Users/iana/.rvm/rubies/ruby-1.9.2-p180/bin:/Users/iana/.rvm/bin:/opt/local/bin:/opt/local/sbin:/Users/iana/bin:/usr/local/bin:/usr/local/sbin:/Users/iana:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/X11/bin

alias reload='source ~/.zshrc'
alias editbash='subl -w ~/.bashrc ~/.bash_profile ~/.bash/env ~/.bash/config ~/.bash/aliases && reload'
alias editzsh='subl -w ~/.zshrc && reload'
alias la="ls -alGhF"
alias dir='ls -alf'
alias cls='clear; ls'
alias l.='ls -d .[^.]*' #only show .dot files
alias grep="grep --color=auto"
alias gzip="gzip -9n" # set strongest compression level as ‘default’ for gzip
alias ping="ping -c 5" # ping 5 times ‘by default’
alias ql="qlmanage -p 2>/dev/null" # preview a file using QuickLook

# Get readable list of network IPs
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
#My IP address
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
#useful info
alias kext3="kextstat | grep -v com.apple" #find 3rd party kernel extensions
alias mydisplay="ioreg -lw0 | grep IODisplayEDID | sed \"/[^<]*</s///\" | xxd -p -r | strings -6" #find id of display
alias whywakeme="syslog |grep -i \"Wake reason =\"" #find why the machine woke up
alias powerlog="pmset -g pslog" #log of active power/sleep info

# Flush DNS cache
alias flushdns="sudo dscacheutil -flushcache"

function wireshark() {
	sudo chgrp admin /dev/bpf*
	sudo chmod g+rw /dev/bpf*
}

printf '\e[36m'
printf 'Current date: '
date
printf '\e[32m'
printf 'Uptime: '
uptime
printf '\e[m'
printf '\e[33m'
df -h | grep disk0s2 | awk '{print "Mac HD:", $2, "total,", $3, "used,", $4, "remaining"}'
# I don't care about my Windows HD, but I might want to enable that in the future. Remove the # to enable
#df -h | grep disk0s3 | awk '{print "Windows HD:", $2, "total,", $3, "used,", $4, "remaining"}'
echo "Architecture: " `sysctl -n machdep.cpu.brand_string;`
echo "Memory: " `sw_vers | awk -F':t' '{print $2}' | paste -d ' ' - - -;
sysctl -n hw.memsize | awk '{print $0/1073741824" GB RAM"}';` 
echo "LAN IP Address: " `ifconfig en0 | grep "inet" | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'`
echo "Wireless IP Address: " `ifconfig en1 | grep "inet" | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'`
printf '\e[m'

figlet "Tarako Hai!"
