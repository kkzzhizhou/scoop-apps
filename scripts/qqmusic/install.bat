@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im QQMusic* >NUL 2>NUL
taskkill /f /im QMWeiyun.exe >NUL 2>NUL
taskkill /f /im qmbrowser.exe >NUL 2>NUL
taskkill /f /im QMSystemEQ.exe >NUL 2>NUL
taskkill /f /im QMDriverHelper* >NUL 2>NUL
taskkill /f /im StartDesktopProjection* >NUL 2>NUL

::注册腾讯软件运行库组件
regsvr32 /s TXSSO\Bin\SSOCommon.dll
regsvr32 /s TXSSO\Bin\SSOLUIControl.dll
regsvr32 /s TXSSO\Bin\npSSOAxCtrlForPTLogin.dll

::注册浏览器快速登陆组件
regsvr32 /s QQMusic_Login.dll

::注册相关组件
QQMusicSvr.exe /RegServer
QQMusicAgent.exe /regqmfiles
QQMusicAgent.exe /prefetch "%~dp0\"
QQMusicAgent.exe /collecthardwareinfo
QQMusicAgent.exe /CheckDirect2D
QQMusicAgent.exe /CheckDirect3D9ForMVPlay
QQMusicAgent.exe /writehardwareinfo

::设置默认播放器
::QQMusicAgent.exe /regqmfiles
::QQMusicAgent.exe /regmediafiles

::清除注册组件残留文件
rd/s/q "%TEMP%\QQMusicInstaller"2>NUL
rd/s/q "%AppData%\Tencent\Logs"2>NUL
del/f/q "%AppData%\Tencent\QQMusic\updateinfo.ini"2>NUL

::软件路径检测键值
IF NOT EXIST "%ProgramW6432%" (
reg add "HKLM\Software\Tencent\QQMusic" /f /v "Install" /d "%~dp0\" >NUL
) ELSE (
reg add "HKLM\Software\Tencent\QQMusic" /f /v "Install" /d "%~dp0\" /reg:32 >NUL
)

ECHO.&ECHO Done.
