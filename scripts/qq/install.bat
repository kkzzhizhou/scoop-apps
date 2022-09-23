@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im QQSetupEx.exe >NUL 2>NUL
taskkill /f /im QQProtect.exe >NUL 2>NUL
taskkill /f /im TXPlatform.exe >NUL 2>NUL
taskkill /f /im QQExternal.exe >NUL 2>NUL
taskkill /f /im QQScLauncher.exe >NUL 2>NUL
taskkill /f /im QQGuild.exe /t >NUL 2>NUL
taskkill /f /im QQApp.exe >NUL 2>NUL
taskkill /f /im QQ.exe /t >NUL 2>NUL

::注册网页关联、表情包类型、下载组件等协议
if exist Bin\TXPlatform.exe Bin\TXPlatform.exe /RegServer
if exist Bin\AppCom.dll regsvr32 /s Bin\AppCom.dll
if exist Bin\Common.dll regsvr32 /s Bin\Common.dll
if exist Bin\KernelUtil.dll regsvr32 /s Bin\KernelUtil.dll
if exist Bin\TXPFProxy.dll regsvr32 /s Bin\TXPFProxy.dll
if exist Bin\CPHelper.dll regsvr32 /s Bin\CPHelper.dll
if exist Bin\Timwp.dll regsvr32 /s Bin\Timwp.dll
if exist Bin\DownloadProxyPS.dll regsvr32 /s Bin\DownloadProxyPS.dll
if exist Bin\QQExternal.exe Bin\QQExternal.exe /SetupRegister

::注册腾讯软件运行库组件
if exist Bin\TXSSO regsvr32 /s Bin\TXSSO\Bin\SSOLUIControl.dll
if exist Bin\TXSSO regsvr32 /s Bin\TXSSO\Bin\npSSOAxCtrlForPTLogin.dll

::注册浏览器快速登陆组件
if exist Bin\TXSSO\Npchrome regsvr32 /s Bin\TXSSO\Npchrome\npactivex.dll

::注册群共享微云上传组件
regsvr32 /s Plugin\Com.Tencent.NetDisk\Bin\QQDisk\Bin\TXFTNActiveX.dll

::清除注册组件及相关残留数据
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
rd/s/q "%AppData%\Tencent\libsdk"2>NUL
rd/s/q "%AppData%\Tencent\beacon"2>NUL
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
rd/s/q "%LocalAppData%\Tencent\QQGuild"2>NUL
rd/s/q "%LocalAppData%\qq_guild-updater"2>NUL
rd/s/q "%LocalAppData%\Tencent\MiniBrowser"2>NUL
rd/s/q "%Public%\Documents\Tencent"2>NUL
for /f "skip=2 tokens=3 " %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v personal') do (
for /f "delims=*" %%j in ('echo %%i') do rd /s /q "%%j\Tencent Files\All Users\QQ\Misc\OperateFace" >NUL 2>NUL)

IF NOT EXIST "%ProgramW6432%" (
::标记软件检测路径(安装视频留言和影音播放等组件下载需要)
reg add "HKLM\Software\Tencent\QQ2009" /f /v "Install" /d "%~dp0\" >NUL 2>NUL
::标记软件版本号(企业类型网页会话需要,CRM组件也需要保留)
reg add "HKLM\Software\Tencent\QQ2009" /f /v "version" /d "59.11.0.28774.0" >NUL 2>NUL
reg add "HKLM\Software\Tencent\QQ2009" /f /v "rversion" /d "0.27236.0.28774.0" >NUL 2>NUL
) ELSE (
reg add "HKLM\Software\Tencent\QQ2009" /f /v "Install" /d "%~dp0\" /reg:32 >NUL 2>NUL
reg add "HKLM\Software\Tencent\QQ2009" /f /v "version" /d "59.11.0.28774.0" /reg:32 >NUL 2>NUL
reg add "HKLM\Software\Tencent\QQ2009" /f /v "rversion" /d "0.27236.0.28774.0" /reg:32 >NUL 2>NUL
)
::标记QQ频道检测路径
reg add "HKCU\SOFTWARE\Tencent\QQGuild" /f /v "KeepShortcuts" /d "true" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Tencent\QQGuild" /f /v "ShortcutName" /d "QQGuild" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Tencent\QQGuild" /f /v "DisplayVersion" /d "1.3.14-bk.4022" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Tencent\QQGuild" /f /v "InstallLocation" /d "%LocalAppData%\Tencent\QQGuild\1.3.14-bk.4022" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Tencent\QQGuild" /f /v "Executable" /d "%LocalAppData%\Local\Tencent\QQGuild\1.3.14-bk.4022\QQGuild.exe" >NUL 2>NUL

::解决Windows 7或更高版开启UAC用户账户控制清空下数据保存位置更改失败问题
ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL && (
SET Data=^& echo
if not exist "%Public%\Documents\Tencent\QQ\UserDataInfo.ini" md "%Public%\Documents\Tencent\QQ" 2>NUL
if not exist "%Public%\Documents\Tencent\QQ\UserDataInfo.ini" echo.%Data%>>"%Public%\Documents\Tencent\QQ\UserDataInfo.ini" 2>NUL
)

::创建桌面快捷方式
::mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\腾讯QQ.lnk""):b.TargetPath=""%~sdp0Bin\QQScLauncher.exe"":b.WorkingDirectory=""%~sdp0Bin"":b.Save:close")

ECHO.&ECHO 完成 &TIMEOUT /t 3 >NUL&EXIT
