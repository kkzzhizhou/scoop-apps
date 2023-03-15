@cd /d "%~dp0"

regsvr32.exe /s /u PWRISOSH.DLL
PWRISOVM.exe 998
devcon.exe remove *scdbusDevice
setup64.exe rm $0 C:\WINDOWS\system32\Drivers\scdemu.sys

@exit 0
