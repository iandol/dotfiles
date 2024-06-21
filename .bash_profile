if [ -f ~/.bashrc ];
then
	source ~/.bashrc
fi

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
