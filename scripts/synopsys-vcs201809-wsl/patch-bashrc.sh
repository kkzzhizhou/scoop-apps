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

cp -rf ${PWD}/.synopsys-vcs201809.bashrc ~/.synopsys-vcs201809.bashrc

grep -qxF '###--> CVP.BASHRC.synopsys-vcs201809' ~/.bashrc || ( \
    echo -e '\n'; \
    echo '###--> CVP.BASHRC.synopsys-vcs201809'; \
    echo 'if [ -f ~/.synopsys-vcs201809.bashrc ]; then'; \
    echo '    . ~/.synopsys-vcs201809.bashrc'; \
    echo 'fi'; \
    echo '###<-- CVP.BASHRC.synopsys-vcs201809'; \
    echo -e '\n' \
) >> ~/.bashrc
