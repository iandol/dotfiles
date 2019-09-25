#!/bin/zsh
cd /System/Library/Extensions
sudo mount -u -w / #need to remount as R/W
echo "\n\List /System/Library/Extensions directory for Psy*:"
ls -d Psy*
echo "\n\nIs PsychtoolboxKernelDriver Currently Installed:"
kextstat -b PsychtoolboxKernelDriver
read -p "prompt"
echo "\n\nRemoving old driver, installing update..."
sudo kextunload -b PsychtoolboxKernelDriver
sleep 1
sudo rm -rf PsychtoolboxKernelDriver.kext
sudo unzip ~/Code/Psychtoolbox/Psychtoolbox/PsychHardware/PsychtoolboxKernelDriverUpTodDate_Unsigned.kext.zip
sleep 1
echo "\n\nTrying to load new driver (this may fail, if so disable SIP)"
sleep 1
sudo kextload -b PsychtoolboxKernelDriver
kextstat -b PsychtoolboxKernelDriver
read -p "prompt"
#echo "\n\nSetting kext override loading for Yosemite+ (boot-args='kext-dev-mode=1'); reboot if this is the first time you do this"
#ma