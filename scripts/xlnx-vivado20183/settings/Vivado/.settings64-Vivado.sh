##############################################################
# Copyright (c) 1986-2020 Xilinx, Inc.  All rights reserved. #
##############################################################

export XILINX_VIVADO='%TOOL_INST_PATH%\Vivado\2018.3'
if [ -n "${PATH}" ]; then
  export PATH='%TOOL_INST_PATH%\Vivado\2018.3\bin:%TOOL_INST_PATH%\Vivado\2018.3\lib\win64.o':$PATH
else
  export PATH='%TOOL_INST_PATH%\Vivado\2018.3\bin:%TOOL_INST_PATH%\Vivado\2018.3\lib\win64.o'
fi
