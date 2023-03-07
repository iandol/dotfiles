$proxy='http://127.0.0.1:16005'
$ENV:HTTP_PROXY=$proxy
$ENV:HTTPS_PROXY=$proxy
$ENV:ALL_PROXY=$proxy
$ENV:HOME=$ENV:USERPROFILE
$ENV:USER=$ENV:USERNAME
$ENV:XDG_CONFIG_HOME=$ENV:USERPROFILE+"\.config"

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex  
scoop install sudo git 7zip ln

git config --global http.proxy $proxy
git config --global https.proxy $proxy

scoop bucket add extras 
scoop bucket add versions 
scoop bucket add nerd-fonts
scoop bucket add nonportable
scoop install sysinternals

scoop install process-explorer starship less delta curl gzip tar lsd bat coreutils msys2 vim neovim
scoop install libreoffice sumatrapdf vcredist2022 vivaldi-snapshop wechat 

scoop install vscode
reg import "C:\Users\Ian\scoop\apps\vscode\current\install-context.reg"
reg import "C:\Users\Ian\scoop\apps\vscode\current\install-associations.reg"

sudo scoop install files-np Cascadia-Code FantasqueSansMono-NF FiraCode-NF

cd ~
git clone https://github.com/iandol/dotfiles .dotfiles

New-Item -Path $ENV:HOME\Documents\PowerShell -ItemType Directory
Copy-Item $ENV:HOME\.dotfiles\configs\Microsoft.PowerShell_profile.ps1 $ENV:HOME\Documents\PowerShell\
