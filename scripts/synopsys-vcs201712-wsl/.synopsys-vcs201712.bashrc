###--> CVP.BASHRC

# Synopsys
export SYNOPSYS=/usr/synopsys
export SCL_VER=2017.12
export VCS_VER=N-2017.12-SP2
export VERDI_VER=L-2016.06-1
export UVM_VER=1.1d

# SCL
export SCL_HOME=$SYNOPSYS/scl/${SCL_VER}

# UVM
export UVM_HOME=$SYNOPSYS/uvm-${UVM_VER}

# VCS
export VCS_HOME=$SYNOPSYS/vcs-mx/${VCS_VER}
# dve
export DVE_HOME=$VCS_HOME/gui/dve

# verdi
export VERDI_HOME=$SYNOPSYS/verdi/Verdi3_${VERDI_VER}
export NOVAS_HOME=$SYNOPSYS/verdi/Verdi3_${VERDI_VER}
export FSDB_HOME=$VERDI_HOME/share/PLI/VCS/LINUX64

export PATH=$PATH:$DVE_HOME/bin:$VCS_HOME/bin
export PATH=$PATH:$VERDI_HOME/bin:$VERDI_HOME/platform/LINUX64/bin
export PATH=$PATH:$SCL_HOME/linux64/bin

export LD_LIBRARY_PATH=$FSDB_HOME

# HOSTNAME
export SNPSLMD_LICENSE_FILE=27000@$HOSTNAME
export LM_LICENSE_FILE=27000@$HOSTNAME
export VCS_ARCH_OVERRIDE=linux
export VCS_TARGET_ARCH=amd64

# export DISPLAY=unix:0
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0

alias vcs64="vcs -full64"
alias verdi64="verdi -full64 &"
alias dve64="dve -full64 &"

#alias lmli2="lmgrd -c $SYNOPSYS/Synopsys.dat -l $SYNOPSYS/lmgrd.log"
alias lmli2="lmgrd -c $SYNOPSYS/Synopsys.dat"

# eth0mac=$(ifconfig eth0 | grep ether | awk '{print $2; exit;}' | sed 's/://g')
# sed "1c SERVER $HOSTNAME $eth0mac 27000" -i $SYNOPSYS/Synopsys.dat

###<-- CVP.BASHRC
