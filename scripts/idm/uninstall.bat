@ECHO OFF&PUSHD %~DP0 &TITLE 卸载

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:Uninst
taskkill /f /im IDM* >NUL 2>NUL
taskkill /f /im IEMon* >NUL 2>NUL

regsvr32 /s /u idmfsa.dll downlWithIDM.dll
regsvr32 /s /u IDMIECC.dll IDMGetAll.dll IDMShellExt.dll
If Exist "%WinDir%\SysWOW64" regsvr32 /s /u IDMIECC64.dll
If Exist "%WinDir%\SysWOW64" regsvr32 /s /u downlWithIDM64.dll
If Exist "%WinDir%\SysWOW64" regsvr32 /s /u IDMGetAll64.dll
If Exist "%WinDir%\SysWOW64" regsvr32 /s /u IDMShellExt64.dll

If Exist "%Public%" idmBroker.exe -unRegServer
If Exist "%Public%" Uninstall.exe -uninstdriv

If Exist "%Public%" Net Stop IDMWFP >NUL 2>NUL
If Not Exist "%Public%" Net Stop IDMTDI >NUL 2>NUL

If Exist "%Public%" Rundll32 setupapi.dll,InstallHinfSection DefaultUninstall 128 .\idmwfp.inf
If Not Exist "%Public%" Rundll32 setupapi.dll,InstallHinfSection DefaultUninstall 128 .\idmtdi.inf

rd/s/q "%AppData%\IDM" 2>NUL
rd/s/q "%ProgramData%\IDM" 2>NUL
rd/s/q "%AllUsersProfile%\Application Data\IDM" 2>NUL

reg delete "HKLM\SOFTWARE\Internet Download Manager" /f>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\Internet Download Manager" /f>NUL 2>NUL

taskkill /f /im explorer.exe >NUL 2>NUL & start explorer
reg delete "HKCU\Software\DownloadManager" /f>NUL 2>NUL
