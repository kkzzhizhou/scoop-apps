@ECHO OFF&PUSHD %~DP0 &TITLE 卸载

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:Remove
regsvr32 /s /u HaoZipExt.dll
rd /s /q "%APPDATA%\HaoZip" 2>NUL
reg delete HKCU\Software\2345.com /f >NUL 2>NUL
taskkill /f /im explorer.exe
start explorer
exit
