if [[ $PLATFORM = "Darwin" ]]; then
	# Setup fzf
	if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
		export PATH="$PATH:/usr/local/opt/fzf/bin"
	fi
	# Auto-completion
	[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null
	# Key bindings
	source "/usr/local/opt/fzf/shell/key-bindings.bash"
else
	# Setup fzf
	if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/fzf/bin* ]]; then
		export PATH="$PATH:/home/linuxbrew/.linuxbrew/opt/fzf/bin"
	fi
	# Auto-completion
	[[ $- == *i* ]] && source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.bash" 2> /dev/null
	# Key bindings
	source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.bash"
fi
