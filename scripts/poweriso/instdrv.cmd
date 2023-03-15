@cd /d "%~dp0"

devcon.exe remove *scdbusDevice
setup64.exe cp $0 C:\WINDOWS\system32\Drivers\scdemu.sys

@exit 0
