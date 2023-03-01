@ECHO OFF & PUSHD "%~DP0"
REG QUERY "HKU\S-1-5-19">NUL 2>&1 || (
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0release\x64\x64dbg.exe" /d "~ RUNASADMIN" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0release\x32\x32dbg.exe" /d "~ RUNASADMIN" >NUL 2>NUL
)
REG QUERY "HKU\S-1-5-19">NUL 2>&1 || (powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

reg delete "HKLM\SOFTWARE\Classes\.dd32" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.dd64" /f >NUL 2>NUL
reg delete "HKLM\exefile\Shell\Debug with x32dbg" /f >NUL 2>NUL
reg delete "HKLM\exefile\Shell\Debug with x64dbg" /f >NUL 2>NUL
reg delete "HKLM\dllfile\Shell\Debug with x32dbg" /f >NUL 2>NUL
reg delete "HKLM\dllfile\Shell\Debug with x64dbg" /f >NUL 2>NUL
reg delete "HKCR\dllfile\Shell\Debug with x64dbg" /f >NUL 2>NUL
reg delete "HKCR\dllfile\Shell\Debug with x32dbg" /f >NUL 2>NUL
reg delete "HKCR\exefile\Shell\Debug with x64dbg" /f >NUL 2>NUL
reg delete "HKCR\exefile\Shell\Debug with x32dbg" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0release\x64\x64dbg.exe" >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0release\x32\x32dbg.exe" >NUL 2>NUL
del/q "%UserProfile%\桌面\x*dbg.lnk" >NUL 2>NUL
del/q "%AllUsersProfile%\桌面\x*dbg.lnk" >NUL 2>NUL
del/q "%Public%\Desktop\x*dbg.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\x*dbg.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\x*dbg.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\x*dbg.lnk" >NUL 2>NUL
ECHO.&ECHO 删除完成
ECHO.&ECHO ghxi.com
TIMEOUT /t 3 >NUL&EXIT
