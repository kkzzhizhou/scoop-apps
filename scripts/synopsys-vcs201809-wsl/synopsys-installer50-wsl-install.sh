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
version=N-2018.09
installer_version=v5.0

sudo add-apt-repository ppa:linuxuprising/libpng12
sudo apt update
sudo apt-get install -y libpng12-0

# 'cshell' is required to run the installer
sudo apt-get install -y --no-install-recommends csh
sudo apt-get install -y lsb-core bc libjpeg62-dev net-tools

# wget -q -O /tmp/libpng12.deb http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
#   && sudo dpkg -i /tmp/libpng12.deb \
#   && rm /tmp/libpng12.deb

[ -d /usr/tmp ] || sudo mkdir /usr/tmp
[ -f /usr/tmp/.flexlm ] || sudo touch /usr/tmp/.flexlm
[ -d ${base_dir} ] || sudo mkdir -p ${base_dir}
sudo chown $USER:$USER ${base_dir}

chmod +x ./SynopsysInstaller_${installer_version}.run
./SynopsysInstaller_${installer_version}.run -dir ${base_dir}/installer_${installer_version}

touch ./.install.done
