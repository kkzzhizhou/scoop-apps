@ECHO OFF&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im computerz_cn.exe >NUL 2>NUL
taskkill /f /im ComputerZService.exe >NUL 2>NUL
taskkill /f /im BenchmarkLauncher* /t >NUL 2>NUL
taskkill /f /im Display3DEx.exe >NUL 2>NUL

rd/s/q "%AppData%\lds" 2>NUL
rd/s/q "%AppData%\DrvMgr"2>NUL
rd/s/q "%AppData%\Ludashi"2>NUL

reg delete "HKCU\Software\Ludashi" /f >NUL 2>NUL
reg delete "HKCU\Software\QiLu Inc." /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\ldssrv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Ludashi" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\ComMaster" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\ComputerZ" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\LiveUpdate360" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\360Safe\Liveup" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\ldssrv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\Ludashi" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\ComMaster" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\ComputerZ" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\LiveUpdate360" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\360Safe\Liveup" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\services\HpSvc" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\services\ComputerZ_x64" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\services\HardwareProtect" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ComputerZ_CN.exe" /f >NUL 2>NUL

ECHO.&ECHO 清除完成 &TIMEOUT /t 2 >NUL&EXIT
