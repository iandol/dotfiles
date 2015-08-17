#!/bin/zsh
cd /System/Library/Extensions
echo "\n\nCheck directory:"
sudo ls -al Psy*
echo "\n\nIs PsychtoolboxKernelDriver Currently Installed:"
kextstat -b PsychtoolboxKernelDriver
read -p "prompt"
echo "\n\nRemoving old driver, installing update..."
sudo kextunload -b PsychtoolboxKernelDriver
sleep 1
sudo rm -rf PsychtoolboxKernelDriver.kext
sudo unzip ~/Code/Psychtoolbox-3/Psychtoolbox/PsychHardware/PsychtoolboxKernelDriver64Bit.kext.zip
sleep 1
echo "\n\nTrying to load new driver (this may fail on Yosemite, will need to change boot options)"
sudo kextload -b PsychtoolboxKernelDriver
kextstat -b PsychtoolboxKernelDriver
read -p "prompt"
echo "\n\nSetting kext override loading for Yosemite+ (boot-args='kext-dev-mode=1'); reboot if this is the first time you do this"
sudo nvram boot-args="-v"