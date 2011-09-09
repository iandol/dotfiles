printf '\e[36m'
printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
ln -siv .zshrc ~/.zshrc
ln -siv .bashrc ~/.bashrc
ln -siv .bash_profile ~/.bash_profile
printf '\e[36m'
printf 'Done...\n'
printf '\e[m'
