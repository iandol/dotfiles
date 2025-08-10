#!/usr/bin/env zsh
export MAMBA_EXE="/home/cog/.local/bin/micromamba";
export MAMBA_ROOT_PREFIX="/media/cogp/micromamba";
if [ -x $MAMBA_EXE ] && [ -d $MAMBA_ROOT_PREFIX ]; then
    eval "$(micromamba shell hook --shell=zsh)"
    micromamba info
    micromamba activate octave
    octave --gui
fi
