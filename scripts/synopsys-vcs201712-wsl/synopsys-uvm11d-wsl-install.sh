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
tool=uvm
version=1.1d
installer_version=v3.5

[ -d ${base_dir}/installer_${installer_version} ] || ( print '${base_dir}/installer_${installer_version} Not exist!!!' && exit 1 )

tar xf uvm-${version}.tar.gz -C ${base_dir}/
