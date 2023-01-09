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

base_dir=/usr/synopsys
tool=vcs
version=N-2017.12
installer_version=v3.5

[ -d ${base_dir}/installer_${installer_version} ] || ( print '${base_dir}/installer_${installer_version} Not exist!!!' && exit 1 )

echo 'yes' | ${base_dir}/installer_${installer_version}/batch_installer -install_as_root -source ${PWD}/ -target ${base_dir}/ -allprods
