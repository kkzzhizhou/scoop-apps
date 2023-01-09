@echo off
cd /d "%~dp0"

SET "VIVADO_VER=2018.3"
SET "VIVADO_BIT=64"

cd /d Programs/data/xicom/cable_drivers/nt64/dlc10_win7
wdreg -compat -inf %cd%\windrvr6.inf uninstall
wdreg -compat -inf %cd%\xusbdrvr.inf uninstall
wdreg -compat -inf %cd%\windrvr6.inf install
wdreg -compat -inf %cd%\xusbdrvr.inf install

@echo ::Install finished
DELAY 5 2>nul || ping -n 5 127.0.0.1>nul
EXIT 0
