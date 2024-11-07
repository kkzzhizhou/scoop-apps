@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im TIM.exe /t >NUL 2>NUL
taskkill /f /im TIMApp.exe >NUL 2>NUL
taskkill /f /im QQProtect.exe >NUL 2>NUL
taskkill /f /im TXPlatform.exe >NUL 2>NUL
taskkill /f /im QQExternal.exe >NUL 2>NUL
taskkill /f /im QQScLauncher.exe >NUL 2>NUL

::注册腾讯软件运行库组件
if exist Bin\TXSSO regsvr32 /s Bin\TXSSO\Bin\SSOLUIControl.dll
if exist Bin\TXSSO regsvr32 /s Bin\TXSSO\Bin\npSSOAxCtrlForPTLogin.dll

::注册浏览器快速登陆组件
if exist Bin\TXSSO\Npchrome regsvr32 /s Bin\TXSSO\Npchrome\npactivex.dll

::注册群共享微云上传组件
regsvr32 /s Plugin\Com.Tencent.NetDisk\Bin\QQDisk\Bin\TXFTNActiveX.dll

::注册网页关联、表情包类型、下载组件等协议
if exist Bin\Timwp.dll regsvr32 /s Bin\Timwp.dll
if exist Bin\AppCom.dll regsvr32 /s Bin\AppCom.dll
if exist Bin\TXPFProxy.dll regsvr32 /s Bin\TXPFProxy.dll
if exist Bin\KernelUtil.dll regsvr32 /s Bin\KernelUtil.dll
if exist Bin\TXPlatform.exe Bin\TXPlatform.exe /RegServer
if exist Bin\QQExternal.exe Bin\QQExternal.exe /SetupRegister
if exist Bin\DownloadProxyPS.dll regsvr32 /s Bin\DownloadProxyPS.dll

::清除注册组件及相关残留数据
rd/s/q "%AppData%\Tencent\TIM" 2>NUL
rd/s/q "%AppData%\Tencent\Logs" 2>NUL
rd/s/q "%AppData%\Tencent\TXSSO" 2>NUL
rd/s/q "%AppData%\Tencent\QTalk"2>NUL
rd/s/q "%AppData%\Tencent\libsdk"2>NUL
rd/s/q "%AppData%\Tencent\QQLite"2>NUL
rd/s/q "%AppData%\QQAppAssistant"2>NUL
rd/s/q "%AppData%\Tencent\Common"2>NUL
rd/s/q "%AppData%\Tencent\libsdk"2>NUL
rd/s/q "%AppData%\Tencent\beacon"2>NUL
rd/s/q "%AppData%\Tencent\SafeBas"2>NUL
rd/s/q "%AppData%\Tencent\QQPCMGR"2>NUL
rd/s/q "%APPDATA%\Tencent\QQDoctor"2>NUL
rd/s/q "%AppData%\Tencent\QQTempSys"2>NUL
rd/s/q "%AppData%\Tencent\Tencentdl" 2>NUL
rd/s/q "%AppData%\Tencent\DeskUpdate"2>NUL
rd/s/q "%AppData%\Tencent\QQDownload" 2>NUL
rd/s/q "%AppData%\Tencent\QQ\QQProtect" 2>NUL
rd/s/q "%AppData%\Tencent\AndroidAssist"2>NUL
rd/s/q "%AppData%\Tencent\AndroidServer"2>NUL
rd/s/q "%AppData%\Tencent\QQPhoneManager"2>NUL
rd/s/q "%AppData%\Tencent\QQ\commonf_inst" 2>NUL
rd/s/q "%AppData%\Tencent\QQPhoneAssistant"2>NUL
rd/s/q "%AppData%\Tencent\QQ\QQAntiPhishing" 2>NUL
del/f/q "%AppData%\Tencent\QQCall*.exe">NUL 2>NUL

IF NOT EXIST "%ProgramW6432%" (
::标记软件检测路径(安装视频留言和影音播放等组件下载需要)
reg add "HKLM\Software\Tencent\TIM" /f /v "Install" /d "%~dp0\" >NUL 2>NUL
::标记软件版本号(企业类型网页会话需要,CRM组件也需要保留)
reg add "HKLM\Software\Tencent\TIM" /f /v "version" /d "56.57.0.22051.0" >NUL 2>NUL
) else (
reg add "HKLM\Software\Tencent\TIM" /f /v "Install" /d "%~dp0\" /reg:32 >NUL 2>NUL
reg add "HKLM\Software\Tencent\TIM" /f /v "version" /d "56.57.0.22051.0" /reg:32 >NUL 2>NUL
)

::解决Windows 7或更高版在开启UAC用户账户控制情况下更改数据保存位置失败问题
ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL && (
SET Data=^& echo
if not exist "%Public%\Documents\Tencent\QQ\UserDataInfo.ini" md "%Public%\Documents\Tencent\QQ" 2>NUL
if not exist "%Public%\Documents\Tencent\QQ\UserDataInfo.ini" echo.%Data%>>"%Public%\Documents\Tencent\QQ\UserDataInfo.ini" 2>NUL
)

ECHO.&ECHO 完成 &TIMEOUT /t 3 >NUL&EXIT
