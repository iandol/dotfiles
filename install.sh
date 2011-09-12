printf '\e[36m'
printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
ln -siv .zshrc ~/
ln -siv .bashrc ~/
ln -siv .bash_profile ~/
printf '\e[36m'
printf 'Done...\n'
printf '\e[m'
