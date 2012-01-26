printf '\e[36m'
printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
ln -siv ~/.bash/.zshrc ~/
ln -siv ~/.bash/.bashrc ~/
ln -siv ~/.bash/.bash_profile ~/
printf '\e[36m'
printf '\nCopying zsh theme if oh-my-zsh is installed...\n'
if [ -d ~/.oh-my-zsh/custom ]; then
	cp ~/.bash/*theme ~/.oh-my-zsh/custom/
	printf 'Theme copied over...\n'
else
	printf 'Couldnt find .oh-my-zsh\n'
fi
printf 'Done...\n'
printf '\e[m'
