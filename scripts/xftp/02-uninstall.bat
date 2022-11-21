@chcp 65001&cls
@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im Xftp* >NUL 2>NUL

rd/s/q "%ProgramData%\NetSarang" 2>NUL
rd/s/q "%AllUsersProfile%\NetSarang\Xftp"2>NUL
del/f/q "%PUBLIC%\Desktop\Xftp.lnk" >NUL 2>NUL
del/f/q "%UserProfile%\Desktop\Xftp.lnk" >NUL 2>NUL
del/f/q "%AllUsersProfile%\Desktop\Xftp.lnk" >NUL 2>NUL

reg delete "HKCU\Software\NetSarang\Xftp" /F>NUL 2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Common" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Xftp" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\NetSarang\Common" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\NetSarang\Xftp" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /v "%~dp0XftpCore.tlb" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\SharedDlls" /v "%~dp0XftpCore.tlb" /f >NUL 2>NUL
EXIT

reg delete "HKLM\SOFTWARE\Classes\.xsh" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.xts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{28CDE56E-0823-4779-846E-EF8279D08F48}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{3C46F82A-A7E8-411D-8CBD-348A8F637DEB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{412941DD-D839-4F04-964A-B848505BED0F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{6C51A006-7BBF-4CB5-97BA-BE817AE8F676}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{C5F52903-5CCF-4045-A3FD-38C96AFEE001}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{E07D3360-0EB9-40CF-97BD-C3FD867F76DB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{F9BEB160-712F-4DEE-AF53-6920B63D699B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{76F8E8FE-E047-44E6-80B1-302E70CB6B27}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{28CDE56E-0823-4779-846E-EF8279D08F48}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{3C46F82A-A7E8-411D-8CBD-348A8F637DEB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{412941DD-D839-4F04-964A-B848505BED0F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{6C51A006-7BBF-4CB5-97BA-BE817AE8F676}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{C5F52903-5CCF-4045-A3FD-38C96AFEE001}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{E07D3360-0EB9-40CF-97BD-C3FD867F76DB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{F9BEB160-712F-4DEE-AF53-6920B63D699B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xftp.xsh" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xtransport.xts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xftp.Document" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xactivator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xagent.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xftp.exe" /f >NUL 2>NUL

EXIT

CLS&ECHO.&ECHO 清除完成，删除保存数据?[敲1]
CHOICE /C 1 /N >NUL 2>NUL
IF "%ERRORLEVEL%"=="1" (
  FOR /F "skip=2 tokens=3 " %%i IN ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v personal') DO (
  FOR /F "delims=*" %%j IN ('ECHO;%%i') DO RD /S/Q "%%j\NetSarang" >NUL 2>NUL & rd /s/q "%%j\NetSarang Computer" >NUL 2>NUL )
  ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT )