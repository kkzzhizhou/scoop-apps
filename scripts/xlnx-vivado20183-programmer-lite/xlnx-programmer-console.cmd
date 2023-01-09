@echo off

cd /d "%~dp0"
set "TOPDIR=%cd:\=/%"
title "%~n0"

:: ----------------------------------------
:: setlocal enabledelayedexpansion
:: ----------------------------------------
setlocal enabledelayedexpansion
:: ----------------------------------------

:: ----------------------------------------
set "ORIGIN_PATH=%PATH%"
set "MINI_PATH=C:/WINDOWS/system32;C:/WINDOWS;C:/WINDOWS/System32/Wbem"
set "PATH=%MINI_PATH%"
:: ----------------------------------------

set "XLNX_BURN_TOPDIR=%TOPDIR%"
set "XLNX_BURN_ROOTDIR=%XLNX_BURN_TOPDIR%/Programs/bin"
set "PATH=%XLNX_BURN_ROOTDIR%;%PATH%"

cmd /C program_flash -f target/BOOT.bin -offset 0 -flash_type nand-x8 -fsbl target/fsbl.elf -cable type xilinx_tcf url TCP:127.0.0.1:3121 

@echo ::Burn finished
DELAY 5 2>nul || ping -n 5 127.0.0.1>nul
EXIT 0
