#! /bin/bash
#
# =====
# SPDX-License-Identifier: (GPL-2.0+ OR MIT):
# 
# !!! THIS IS NOT GUARANTEED TO WORK !!!
# 
# Copyright (c) 2018-2022, SayCV
# =====
# 

cp -rf ${PWD}/.fixes-wsl-mac-dynaddr.bashrc ~/.fixes-wsl-mac-dynaddr.bashrc

grep -qxF '###--> CVP.BASHRC.fixes-wsl-mac-dynaddr' ~/.bashrc || ( \
    echo -e '\n'; \
    echo '###--> CVP.BASHRC.fixes-wsl-mac-dynaddr'; \
    echo 'if [ -f ~/.fixes-wsl-mac-dynaddr.bashrc ]; then'; \
    echo '    . ~/.fixes-wsl-mac-dynaddr.bashrc'; \
    echo 'fi'; \
    echo '###<-- CVP.BASHRC.fixes-wsl-mac-dynaddr'; \
    echo -e '\n' \
) >> ~/.bashrc
