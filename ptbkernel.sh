#!/bin/zsh

cd /System/Library/Extensions
sudo kextstat -b PsychtoolboxKernelDriver
sudo kextunload -b PsychtoolboxKernelDriver
sudo rm -rf PsychtoolboxKernelDriver.kext
sudo unzip ~/Code/Psychtoolbox-3/Psychtoolbox/PsychHardware/PsychtoolboxKernelDriver64Bit.kext.zip
sudo kextload -b PsychtoolboxKernelDriver
sudo kextstat -b PsychtoolboxKernelDriver
