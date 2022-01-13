@ECHO OFF&PUSHD %~DP0 &TITLE 卸载
@ echo.
ver|findstr "5\.[0-9]\.[0-9][0-9]*">nul && goto skip
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)
:skip

:: 卸载前结束相关进程
taskkill /f /im TXP* >NUL 2>NUL
taskkill /f /im tad* >NUL 2>NUL
taskkill /f /im QQP* >NUL 2>NUL
taskkill /f /im QQC* >NUL 2>NUL
taskkill /f /im QQ.exe >NUL 2>NUL

::清理相关数据
rd /s /q "%ProgramData%\QQPet"2>NUL
rd /s /q "%AppData%\Tencent\QQ"2>NUL
rd /s /q "%AppData%\QXiu Files"2>NUL
rd /s /q "%AppData%\Tencent\TXSSO"2>NUL
rd /s /q "%AppData%\Tencent\STemp"2>NUL
rd /s /q "%AppData%\Tencent\Users"2>NUL
rd /s /q "%AppData%\Tencent\QTalk"2>NUL
rd /s /q "%AppData%\QQAppAssistant"2>NUL
rd /s /q "%AppData%\Tencent\QQMiniDL"2>NUL
rd /s /q "%AppData%\Tencent\DeskUpdate"2>NUL
rd /s /q "%AppData%\Tencent\QzoneMusic"2>NUL
rd /s /q "%AppData%\Tencent\AndroidAssist"2>NUL
rd /s /q "%AppData%\Tencent\QQPhoneManager"2>NUL
rd /s /q "%AppData%\Tencent\QQMiniDL"2>NUL
rd /s /q "%AppData%\Tencent\Tencentdl"2>NUL
rd /s /q "%AppData%\Tencent\TenioDL"2>NUL
rd /s /q "%AppData%\Tencent\WebGamePlugin"2>NUL
rd /s /q "%AppData%\Tencent\File"2>NUL
rd /s /q "%AppData%\Tencent\Security001"2>NUL
rd /s /q "%ProgramData%\Tencent\QQProtect" 2>NUL
rd /s /q "%UserProFile%\AppData\LocalLow\QQMiniDL"2>NUL
rd /s /q "%UserProfile%\AppData\Local\Tencent\Misc"2>NUL
rd /s /q "%AllUsersProfile%\Application Data\QQPet"2>NUL
rd /s /q "%UserProfile%\AppData\Local\Tencent\MiniBrowser"  2>NUL
rd /s /q "%UserProfile%\AppData\Local\Tencent\QQPet"2>NUL
rd /s /q "%UserProfile%\Local Settings\Tencent\QQPet"2>NUL
rd /s /q "%UserProfile%\Local Settings\QQKartLiveUpdate"2>NUL
rd /s /q "%AllUsersProfile%\Application Data\Tencent\QQProtect"2>NUL
rd /s /q "%CommonProgramFiles%\Tencent\QQProtect"2>NUL
rd /s /q "%CommonProgramFiles(x86)%\Tencent\QQProtect"2>NUL

::卸载所有控件
regsvr32 /s /u Bin\TXSSO\Npchrome\npactivex.dll
regsvr32 /s /u Bin\TXSSO\Bin\SSOCommon.dll
regsvr32 /s /u Bin\TXSSO\Bin\npSSOAxCtrlForPTLogin.dll
regsvr32 /s /u Bin\TXSSO\TXFTN\TXFTNActiveX1.17.dll
regsvr32 /s /u Bin\TXSSO\QzoneMusic\QzoneMusic.dll
if exist Bin\Timwp.dll regsvr32 /s /u Bin\Timwp.dll
if exist Bin\AppCom.dll regsvr32 /s /u Bin\AppCom.dll
if exist Bin\CPHelper.dll regsvr32 /s /u Bin\CPHelper.dll
if exist Bin\TXPFProxy.dll regsvr32 /s /u Bin\TXPFProxy.dll
if exist Bin\KernelUtil.dll regsvr32 /s /u Bin\KernelUtil.dll
if exist Bin\TXPlatform.exe Bin\TXPlatform.exe /UnregServer
if exist Bin\TXSSO\QzoneMusic\QzoneMusic.exe Bin\TXSSO\QzoneMusic\QzoneMusic.exe /UnRegServer
regsvr32 /s /u Plugin\Com.Tencent.NetDisk\Bin\QQDisk\Bin\TXFTNActiveX.dll

::删除注册表键值
reg delete HKCU\Tencent /F  >NUL 2>NUL
reg delete HKLM\Software\Classes\QQPet /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\Plugin /F  >NUL 2>NUL
reg delete HKCU\Software\Tencent\QQ2009 /F  >NUL 2>NUL
reg delete HKLM\Software\Tencent\QQ2009 /F  >NUL 2>NUL
reg delete HKCU\Software\Classes\Tencent /F >NUL 2>NUL
reg delete HKLM\Software\Classes\Tencent /F >NUL 2>NUL
reg delete HKCU\Software\Tencent\QQProtect /F>NUL 2>NUL
reg delete HKCU\Software\Classes\EMOTION.File /F    >NUL 2>NUL
reg delete HKCU\Software\Classes\EMOTION.Package /F >NUL 2>NUL
reg delete HKCU\Software\Tencent\AndroidAssistant /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\AndroidServer /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\bugReport /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\HealthAssistor /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\PLATFORM_CLSID_LIST /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\PlatForm_Type_List /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\QABS99 /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\QQ /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\QQMiniDL /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\TodayDo /F>NUL 2>NUL
reg delete HKCU\Software\Tencent\WebGamePlugin /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\BackupDownloader /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\DeskUpdate /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\MyCubeLogger /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\PcMgrBrowserHp /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\QMAndroidServer /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\QQGame /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\QQPhotoDrawEx /F>NUL 2>NUL
reg delete HKLM\Software\Tencent\Report /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Classes\QQPet /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\QQ2009 /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\BackupDownloader /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\DeskUpdate /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\MyCubeLogger /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\PcMgrBrowserHp /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\QMAndroidServer /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\QQGame /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\QQPhotoDrawEx /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Tencent\Report /F>NUL 2>NUL
reg delete HKLM\Software\Wow6432Node\Classes\Tencent /F>NUL 2>NUL
reg delete HKLM\SYSTEM\CurrentControlSet\services\QQProtect /F>NUL 2>NUL

@REM ::删除桌面图标(只支持系统默认桌面位置)
@REM del /q "%userprofile%\桌面\腾讯QQ.lnk" >NUL 2>NUL
@REM del /q "%userprofile%\Desktop\腾讯QQ.lnk" >NUL 2>NUL
@REM ECHO.&ECHO.卸载完成! &PAUSE >NUL 2>NUL

ECHO. >NUL&EXIT
