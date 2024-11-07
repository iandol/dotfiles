# to run this you may need this first: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser`
$proxy='http://127.0.0.1:16005'
$ENV:HTTP_PROXY=$proxy
$ENV:HTTPS_PROXY=$proxy
$ENV:ALL_PROXY=$proxy
$ENV:HOME=$ENV:USERPROFILE
$ENV:USER=$ENV:USERNAME
$ENV:XDG_CONFIG_HOME=$ENV:USERPROFILE+"\.config"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop bucket add main
scoop install sudo git 7zip ln starship

git config --global http.proxy $proxy
git config --global https.proxy $proxy

scoop bucket add extras 
scoop bucket add versions 
scoop bucket add nerd-fonts
scoop bucket add nonportable
scoop install sysinternals

scoop install less delta curl gzip tar eza bat coreutils msys2 vim neovim
scoop install libreoffice sumatrapdf vcredist2022 vivaldi wechat 

scoop install vscode
reg import "$ENV:HOME\scoop\apps\vscode\current\install-context.reg"
reg import "$ENV:HOME\scoop\apps\vscode\current\install-associations.reg"

sudo scoop install Cascadia-Code FantasqueSansMono-NF FiraCode-NF

cd ~
git clone https://github.com/iandol/dotfiles .dotfiles

New-Item -Path $ENV:HOME\Documents\PowerShell -ItemType Directory
Copy-Item $ENV:HOME\.dotfiles\configs\Microsoft.PowerShell_profile.ps1 $ENV:HOME\Documents\PowerShell\
