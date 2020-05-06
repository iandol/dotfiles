#!/usr/bin/env zsh
ptbroot=~/Code/Psychtoolbox-3/Psychtoolbox
printf "\n=====>>> Update PTB KEXT @ \e[93m$(date)\e[m <<<=====\n"
printf "You need to first disable SIP, or this script will fail...\n\n"
printf "======================================\n Remounting Root to be writable..."
sudo mount -u -w /
cd /System/Library/Extensions
printf "\n======================================\nList /System/Library/Extensions directory for Psy*:\n"
ls -d Psy*
printf "\n\n======================================\nCheck PsychtoolboxKernelDriver Currently Installed?:\n"
kextstat -b PsychtoolboxKernelDriver
read "?Press [enter] to Continue..."
printf "\n\n======================================\nRemoving /System KEXT:\n"
sudo kextunload -b PsychtoolboxKernelDriver
sleep 1
sudo rm -rf PsychtoolboxKernelDriver.kext
printf "\n\n======================================\nRemoving /Library KEXT:\n"
cd /Library/Extensions
sudo kextunload -b PsychtoolboxKernelDriver
sleep 1
sudo rm -rf PsychtoolboxKernelDriver.kext
printf "\n\n======================================\nInstalling latest version:\n"
read "ans?Install new unsigned [y] or old signed [n] kext?   "
if [[ $ans = "y" ]]; then
	sudo unzip $ptbroot/PsychHardware/PsychtoolboxKernelDriverUpTodDate_Unsigned.kext.zip
else
	sudo unzip $ptbroot/PsychHardware/PsychtoolboxKernelDriver64Bit.kext.zip
fi
sleep 1
printf "\n\n======================================\nTrying to load new driver:\n"
sleep 1
sudo kextload -b PsychtoolboxKernelDriver
kextstat -b PsychtoolboxKernelDriver
printf "\n=====>>> Update PTB KEXT Finished @ \e[93m$(date)\e[m <<<=====\n"