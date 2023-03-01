@ECHO OFF&PUSHD %~DP0 &TITLE 绿化

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:Add
md "%APPDATA%\HaoZip">NUL 2>NUL
copy Config\HaoZip.hzc "%APPDATA%\HaoZip">NUL 2>NUL
copy Config\HaoZip.hzv "%APPDATA%\HaoZip">NUL 2>NUL
copy Config\HaoZip.stat "%APPDATA%\HaoZip">NUL 2>NUL
echo.>"%APPDATA%\HaoZip\update" 2>NUL
attrib +r "%APPDATA%\HaoZip\update">NUL 2>NUL
regsvr32 /s HaoZipExt.dll
exit
