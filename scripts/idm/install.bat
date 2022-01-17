@ECHO OFF&PUSHD %~DP0 &TITLE Install

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:Setup
taskkill /f /im IDM* >NUL 2>NUL
taskkill /f /im IEMon* >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Internet Download Manager" /f>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\Internet Download Manager" /f>NUL 2>NUL

::导入注册信息
reg add "HKCU\SOFTWARE\DownloadManager" /f /v "FName" /t REG_SZ /d "Tonec" >NUL
reg add "HKCU\SOFTWARE\DownloadManager" /f /v "LName" /t REG_SZ /d "Inc." >NUL
reg add "HKCU\SOFTWARE\DownloadManager" /f /v "Email" /t REG_SZ /d "info@tonec.com" >NUL
reg add "HKCU\SOFTWARE\DownloadManager" /f /v "Serial" /t REG_SZ /d "IAKZS-OXSQY-00PA3-LFIZA" >NUL

:: Windows All
reg add "HKCU\Software\DownloadManager" /f /v idmvers >NUL
reg add "HKCU\Software\DownloadManager" /f /v ToolbarStyle /d "H3M Glossy" >NUL
reg add "HKCU\Software\DownloadManager" /f /v TipStartUp /t REG_DWORD /d 1 >NUL
reg add "HKCU\Software\DownloadManager" /f /v LaunchOnStart /t REG_DWORD /d 0 >NUL
reg add "HKCU\Software\DownloadManager" /f /v startImmediately /t REG_DWORD /d 0 >NUL
reg add "HKCU\Software\DownloadManager" /f /v FSSettingsChecked /t REG_DWORD /d 1 >NUL
reg add "HKCU\Software\DownloadManager\FoldersTree" /f /v AFD /t REG_DWORD /d 1 >NUL

Start /Wait /B "" "%~dp0IDMan.exe" /rtr /setlngid 2052 /fulllngfile idm_chn2.lng

:: Windows NT6
If Exist "%Public%" idmBroker.exe -RegServer
If Exist "%Public%" Uninstall.exe -instdriv

If Exist "%Public%" Net Start IDMWFP >NUL 2>NUL
If Exist "%Public%" Rundll32 setupapi.dll,InstallHinfSection DefaultInstall 128 .\idmwfp.inf

:: Windows NT
If Not Exist "%Public%" Net Start idmtdi >NUL 2>NUL
If Not Exist "%Public%" Rundll32 setupapi.dll,InstallHinfSection DefaultInstall 128 .\idmtdi.inf

::创建桌面快捷方式
@REM mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\Internet Download Manager.lnk""):b.TargetPath=""%~dp0IDMan.exe"":b.WorkingDirectory=""%~dp0"":b.Save:close")
ECHO.&ECHO 绿化完成，按任意键返回!
