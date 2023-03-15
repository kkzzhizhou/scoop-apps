###--> CVP.BASHRC

wantmac=00:15:5d:7d:e1:2b
mac=$(ip link show bond0 | awk '/ether/ {print $2}')
if [[ $mac !=  $wantmac ]]; then
    sudo ip link set dev bond0 address $wantmac
fi

###<-- CVP.BASHRC
