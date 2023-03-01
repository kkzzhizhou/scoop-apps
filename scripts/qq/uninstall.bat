@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im QQSetupEx.exe >NUL 2>NUL
taskkill /f /im QQProtect.exe >NUL 2>NUL
taskkill /f /im TXPlatform.exe >NUL 2>NUL
taskkill /f /im QQExternal.exe >NUL 2>NUL
taskkill /f /im GVStarter.exe  >NUL 2>NUL
taskkill /f /im QQScLauncher.exe >NUL 2>NUL
taskkill /f /im QQGuild.exe /t >NUL 2>NUL
taskkill /f /im QQApp.exe >NUL 2>NUL
taskkill /f /im QQ.exe /t >NUL 2>NUL

::卸载相关组件
regsvr32 /s /u Bin\TXSSO\Bin\SSOCommon.dll
regsvr32 /s /u Bin\TXSSO\Npchrome\npactivex.dll
regsvr32 /s /u Bin\TXSSO\Bin\npSSOAxCtrlForPTLogin.dll
if exist Bin\Timwp.dll regsvr32 /s /u Bin\Timwp.dll
if exist Bin\AppCom.dll regsvr32 /s /u Bin\AppCom.dll
if exist Bin\CPHelper.dll regsvr32 /s /u Bin\CPHelper.dll
if exist Bin\TXPFProxy.dll regsvr32 /s /u Bin\TXPFProxy.dll
if exist Bin\KernelUtil.dll regsvr32 /s /u Bin\KernelUtil.dll
if exist Bin\TXPlatform.exe Bin\TXPlatform.exe /UnregServer
if exist Bin\DownloadProxyPS.dll regsvr32 /s /u Bin\DownloadProxyPS.dll
regsvr32 /s /u Plugin\Com.Tencent.NetDisk\Bin\QQDisk\Bin\TXFTNActiveX.dll

if exist "%AppData%\Tencent\QQ\QQAntiPhishing\AccountProtect.dll" (
regsvr32 /s /u "%AppData%\Tencent\QQ\QQAntiPhishing\AccountProtect.dll"
)
IF NOT EXIST "%ProgramW6432%" (
if exist ShellExt\QQShellExt.dll regsvr32 /s /u ShellExt\QQShellExt.dll
if exist "%ProgramFiles%\Tencent\QzoneMusic\QzoneMusic.exe" "%ProgramFiles%\Tencent\QzoneMusic\QzoneMusic.exe" /UnRegServer
if exist "%ProgramFiles%\Tencent\QzoneMusic\QzoneMusicUninst.exe" "%ProgramFiles%\Tencent\QzoneMusic\zoneMusicUninst.exe" /S
if exist "%CommonProgramFiles%\Tencent\Npchrome\npactivex.dll" regsvr32 /s /u "%CommonProgramFiles%\Tencent\Npchrome\npactivex.dll"
rd /s/q "%CommonProgramFiles%\Tencent\QQDownload"2>NUL
rd /s/q "%CommonProgramFiles%\Tencent\Npchrome"2>NUL
rd /s/q "%CommonProgramFiles%\Tencent\TXFTN"2>NUL
rd /s/q "%ProgramFiles%\Tencent\QzoneMusic"2>NUL
del /f/q "%WinDir%\System32\TXGYMail*.dll" >NUL 2>NUL
) ELSE (
if exist ShellExt\QQShellExt64.dll regsvr32 /s /u ShellExt\QQShellExt64.dll
if exist "%ProgramFiles(x86)%\Tencent\QzoneMusic\QzoneMusic.exe" "%ProgramFiles(x86)%\Tencent\QzoneMusic\QzoneMusic.exe" /UnRegServer
if exist "%ProgramFiles(x86)%\Tencent\QzoneMusic\QzoneMusicUninst.exe" "%ProgramFiles(x86)%\Tencent\QzoneMusic\zoneMusicUninst.exe" /S
if exist "%ProgramFiles(x86)%\Tencent\Qzone\npQQPhotoDrawEx.dll" regsvr32 /s /u "%ProgramFiles(x86)%\Tencent\Qzone\npQQPhotoDrawEx.dll"
if exist "%CommonProgramFiles(x86)%\Tencent\Npchrome\npactivex.dll" regsvr32 /s /u "%CommonProgramFiles(x86)%\Tencent\Npchrome\npactivex.dll"
rd /s/q "%CommonProgramFiles(x86)%\Tencent\QQDownload"2>NUL
rd /s/q "%CommonProgramFiles(x86)%\Tencent\Npchrome"2>NUL
rd /s/q "%CommonProgramFiles(x86)%\Tencent\TXFTN"2>NUL
rd /s/q "%ProgramFiles(x86)%\Tencent\QzoneMusic"2>NUL
rd /s/q "%ProgramFiles(x86)%\Tencent\Qzone"2>NUL
del /f/q "%WinDir%\SysWOW64\TXGYMail*.dll" >NUL 2>NUL
)

::清除卸载组件及相关残留数据
rd/s/q "%AppData%\od" 2>NUL
del/f/q "%tmp%\*.tvl">NUL 2>NUL
del/f/q "%tmp%\*.tsd">NUL 2>NUL
del/f/q "%tmp%\ts*.dat">NUL 2>NUL
del/f/q "%tmp%\QQSa*.exe">NUL 2>NUL
rd/s/q "%AppData%\qq_guild"2>NUL
rd/s/q "%AppData%\Tencent\OD" 2>NUL
rd/s/q "%AppData%\Tencent\QQ" 2>NUL
rd/s/q "%AppData%\Tencent\IM" 2>NUL
rd/s/q "%AppData%\Tencent\Logs"2>NUL
rd/s/q "%AppData%\Tencent\TXSSO"2>NUL
rd/s/q "%AppData%\Tencent\QTalk"2>NUL
rd/s/q "%AppData%\Tencent\beacon"2>NUL
rd/s/q "%AppData%\Tencent\libsdk"2>NUL
rd/s/q "%AppData%\Tencent\QQLite"2>NUL
rd/s/q "%AppData%\QQAppAssistant"2>NUL
rd/s/q "%AppData%\Tencent\Common"2>NUL
rd/s/q "%AppData%\Tencent\SafeBas"2>NUL
rd/s/q "%AppData%\Tencent\QQPCMGR"2>NUL
rd/s/q "%APPDATA%\Tencent\QQDoctor"2>NUL
rd/s/q "%AppData%\Tencent\QQTempSys"2>NUL
rd/s/q "%AppData%\Tencent\Tencentdl"2>NUL
rd/s/q "%AppData%\Tencent\DeskUpdate"2>NUL
rd/s/q "%AppData%\Tencent\QQDownload"2>NUL
rd/s/q "%AppData%\Tencent\QQ\QQProtect"2>NUL
rd/s/q "%AppData%\Tencent\AndroidAssist"2>NUL
rd/s/q "%AppData%\Tencent\AndroidServer"2>NUL
rd/s/q "%AppData%\Tencent\QQPhoneManager"2>NUL
rd/s/q "%AppData%\Tencent\QQ\commonf_inst"2>NUL
rd/s/q "%AppData%\Tencent\QQPhoneAssistant"2>NUL
rd/s/q "%AppData%\Tencent\QQ\QQAntiPhishing"2>NUL
del/f/q "%AppData%\Tencent\QQCall*.exe">NUL 2>NUL
rd /s/q "%ProgramData%\Tencent\OD" 2>NUL
rd/s/q "%LocalAppData%\Tencent\QQGuild"2>NUL
rd/s/q "%LocalAppData%\qq_guild-updater"2>NUL
rd/s/q "%LocalAppData%\Tencent\MiniBrowser"2>NUL

::清除桌面和开始菜单快捷方式
ver|findstr "5\.[0-9]\.[0-9][0-9]*" >NUL && (
del/q "%UserProfile%\桌面\腾讯QQ.lnk" >NUL 2>NUL
del/q "%AllUsersProfile%\桌面\腾讯QQ.lnk" >NUL 2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\TencentVideoMPlayer"2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\TencentVideoMPlayer"2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\腾讯软件\腾讯QQ"2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\腾讯软件\腾讯QQ"2>NUL )
ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL && (
del/q "%Public%\Desktop\腾讯QQ.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\腾讯QQ.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\TencentVideoMPlayer"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TencentVideoMPlayer"2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\腾讯软件\腾讯QQ"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\腾讯软件\腾讯QQ"2>NUL )

::清除系统程序卸载项
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\QQ" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\QQ" /f /reg:32 >NUL 2>NUL

::清除相关注册表键值
reg delete "HKLM\SOFTWARE\Classes\.eif" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.eip" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.kipx" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\KIPX.File" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\EMOTION.File" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\EMOTION.Package" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\DownloadProxy.EXE" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\DownloadProxy.Downloader" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\DownloadProxy.Downloader.1" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\QQ" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\Report" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\Plugin" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\QQ2009" /F >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Tencent\QQGuild" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\TodayDo" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\QQProtect" /F>NUL 2>NUL
reg delete "HKCU\Software\Tencent\PlatForm_Type_List" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\PLATFORM_CLSID_LIST" /F >NUL 2>NUL
reg delete "HKCU\Software\Classes\EMOTION.File" /F >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\THEMEX.Package" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\EMOTION.Package" /F >NUL 2>NUL
reg delete "HKCU\Software\Tencent\AndroidAssistant" /F>NUL 2>NUL
reg delete "HKEY_USERS\.DEFAULT\Software\Tencent\QQ2009" /F>NUL 2>NUL
reg delete "HKLM\Software\Classes\QQPet" /F>NUL 2>NUL
reg delete "HKLM\Software\Tencent\QQ2009" /F >NUL 2>NUL
reg delete "HKLM\Software\Classes\Tencent" /F >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQPet" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\Software\Tencent\QQ2009" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\Software\Classes\Tencent" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\PlatForm_Type_List" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\QQPhotoDrawEx" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\BackupDownloader" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\PlatForm_Type_List" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\QQPhotoDrawEx" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\BackupDownloader" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\encent\PlatForm_Type_List" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Tracing\QQ_RASAPI32" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Tracing\QQ_RASAPI32" /F /reg:32 >NUL 2>NUL
rd/s/q "%AppData%\Tencent\Logs"2>NUL
rd/s/q "%AppData%\Tencent\QQ" 2>NUL

::删除软件以及当前用户数据
@REM rd/s/q "%Public%\Documents\Tencent"2>NUL
@REM FOR /F "skip=2 tokens=3 " %%i IN ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v personal') DO (
@REM FOR /F "delims=*" %%j IN ('ECHO;%%i') DO RD /S/Q "%%j\Tencent Files" >NUL 2>NUL)
@REM RD /S/Q "%AppData%\Tencent\Users" >NUL 2>NUL
@REM IF EXIST ShellExt DEL /F/Q "ShellExt\*.*" >NUL 2>NUL
@REM IF EXIST ShellExt\QQShellExt.dll ren ShellExt\QQShellExt.dll "QQShellExt.dll.%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
@REM IF EXIST ShellExt\QQShellExt64.dll ren ShellExt\QQShellExt64.dll "QQShellExt64.dll.%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
@REM PUSHD .. & RD /S/Q "%~DP0" >NUL 2>NUL

::删除软件保留当前用户数据
IF EXIST ShellExt DEL /F/Q "ShellExt\*.*" >NUL 2>NUL
IF EXIST ShellExt\QQShellExt.dll ren ShellExt\QQShellExt.dll "QQShellExt.dll.%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
IF EXIST ShellExt\QQShellExt64.dll ren ShellExt\QQShellExt64.dll "QQShellExt64.dll.%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
IF EXIST "users" (
FOR /F "delims=*" %%a IN ('dir /a/b *.*^|findstr /v /i "users$"') DO (
RD /S/Q "%%a" >NUL 2>NUL & DEL /F/Q "%%a" >NUL 2>NUL)
) ELSE (
IF EXIST ShellExt DEL /F/Q "ShellExt\*.*" >NUL 2>NUL
IF EXIST ShellExt\QQShellExt.dll ren ShellExt\QQShellExt.dll "QQShellExt.dll.%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
IF EXIST ShellExt\QQShellExt64.dll ren ShellExt\QQShellExt64.dll "QQShellExt64.dll.%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
PUSHD .. & RD /S/Q "%~DP0" >NUL 2>NUL)
