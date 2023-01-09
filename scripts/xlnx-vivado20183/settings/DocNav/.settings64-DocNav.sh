##############################################################
# Copyright (c) 1986-2020 Xilinx, Inc.  All rights reserved. #
##############################################################

if [ -n "${PATH}" ]; then
  export PATH='%TOOL_INST_PATH%\DocNav':$PATH
else
  export PATH='%TOOL_INST_PATH%\DocNav'
fi
