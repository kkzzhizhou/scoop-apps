@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

::by zd423<https://www.423down.com>

taskkill /f /im Xshell* >NUL 2>NUL

::移除许可服务组件
net stop "FlexNet Licensing Service" >NUL 2>NUL
sc delete "FlexNet Licensing Service" >NUL 2>NUL
rd/s/q "%CommonProgramFiles%\Macrovision Shared"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Macrovision Shared"2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL

::清除软件相关数据
regsvr32 /s /u NsCopyHook3.dll
rd/s/q "%ProgramData%\NetSarang" 2>NUL
rd/s/q "%AllUsersProfile%\NetSarang\Xshell"2>NUL

reg delete "HKCU\Software\NetSarang\Xshell" /F>NUL 2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Common" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Xshell" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Common" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Xshell" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /v "%~dp0XshellCore.tlb" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /v "%~dp0XshellCore.tlb" /f /reg:32 >NUL 2>NUL

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
reg delete "HKLM\SOFTWARE\Classes\Interface\{28CDE56E-0823-4779-846E-EF8279D08F48}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{3C46F82A-A7E8-411D-8CBD-348A8F637DEB}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{412941DD-D839-4F04-964A-B848505BED0F}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{6C51A006-7BBF-4CB5-97BA-BE817AE8F676}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{C5F52903-5CCF-4045-A3FD-38C96AFEE001}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{E07D3360-0EB9-40CF-97BD-C3FD867F76DB}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{F9BEB160-712F-4DEE-AF53-6920B63D699B}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xshell.xsh" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xtransport.xts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xshell.Document" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xactivator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xagent.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xshell.exe" /f >NUL 2>NUL

ECHO. >NUL&EXIT
