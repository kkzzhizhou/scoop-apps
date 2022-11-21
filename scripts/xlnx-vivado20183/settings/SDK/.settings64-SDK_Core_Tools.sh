##############################################################
# Copyright (c) 1986-2020 Xilinx, Inc.  All rights reserved. #
##############################################################

if [ -n "${PATH}" ]; then
  export PATH='%TOOL_INST_PATH%\SDK\2018.3\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\microblaze\nt\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\arm\nt\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\microblaze\linux_toolchain\nt64_le\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch32\nt\gcc-arm-linux-gnueabi\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch32\nt\gcc-arm-none-eabi\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch64\nt\aarch64-linux\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch64\nt\aarch64-none\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\armr5\nt\gcc-arm-none-eabi\bin:%TOOL_INST_PATH%\SDK\2018.3\tps\win64\cmake-3.3.2\bin:%TOOL_INST_PATH%\SDK\2018.3\gnuwin\bin':$PATH
else
  export PATH='%TOOL_INST_PATH%\SDK\2018.3\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\microblaze\nt\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\arm\nt\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\microblaze\linux_toolchain\nt64_le\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch32\nt\gcc-arm-linux-gnueabi\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch32\nt\gcc-arm-none-eabi\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch64\nt\aarch64-linux\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\aarch64\nt\aarch64-none\bin:%TOOL_INST_PATH%\SDK\2018.3\gnu\armr5\nt\gcc-arm-none-eabi\bin:%TOOL_INST_PATH%\SDK\2018.3\tps\win64\cmake-3.3.2\bin:%TOOL_INST_PATH%\SDK\2018.3\gnuwin\bin'
fi
