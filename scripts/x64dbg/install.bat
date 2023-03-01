@ECHO OFF & PUSHD "%~DP0"
REG QUERY "HKU\S-1-5-19">NUL 2>&1 || (
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0release\x64\x64dbg.exe" /d "~ RUNASADMIN" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0release\x32\x32dbg.exe" /d "~ RUNASADMIN" >NUL 2>NUL
)
REG QUERY "HKU\S-1-5-19">NUL 2>&1 || (powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

start "" /wait "%~dp0release\x96dbg.exe"
ECHO.&ECHO 添加完成
ECHO.&ECHO ghxi.com
TIMEOUT /t 3 >NUL&EXIT
