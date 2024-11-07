@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im QQMusic* >NUL 2>NUL
taskkill /f /im QMWeiyun.exe >NUL 2>NUL
taskkill /f /im QMSystemEQ.exe >NUL 2>NUL
taskkill /f /im QMDriverHelper* >NUL 2>NUL
taskkill /f /im StartDesktopProjection* >NUL 2>NUL

::卸载组件
regsvr32 /s /u QQMusic_Login.dll
regsvr32 /s /u TXSSO\Bin\SSOCommon.dll
regsvr32 /s /u TXSSO\Bin\SSOLUIControl.dll
regsvr32 /s /u TXSSO\Bin\npSSOAxCtrlForPTLogin.dll
start /wait QQMusicSvr.exe /UnRegServer
start /wait QQMusicAgent.exe /unregmediafilesForUninstall

::清除残留
rd/s/q "%AppData%\Tencent\Logs"2>NUL
rd/s/q "%AppData%\Tencent\QQMusic"2>NUL
rd/s/q "%AppData%\Macromedia\Flash Player\#SharedObjects\MHPJELSJ\imgcache.qq.com"2>NUL

::清除桌面和开始菜单快捷方式
ver|findstr "5\.[0-9]\.[0-9][0-9]*" >NUL && (
del/q "%UserProfile%\桌面\QQ音乐.lnk" >NUL 2>NUL
del/q "%AllUsersProfile%\桌面\QQ音乐.lnk" >NUL 2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\TencentVideoMPlayer"2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\TencentVideoMPlayer"2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\腾讯软件\QQ音乐"2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\腾讯软件\QQ音乐"2>NUL )
ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL && (
del/q "%Public%\Desktop\QQ音乐.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\QQ音乐.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\TencentVideoMPlayer"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TencentVideoMPlayer"2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\腾讯软件\QQ音乐"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\腾讯软件\QQ音乐"2>NUL )

::清除系统程序卸载项
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\QQMusic" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\QQMusic" /f /reg:32 >NUL 2>NUL

::清除注册表
reg delete "HKCU\Software\Tencent\QQMusic" /F>NUL 2>NUL
reg delete "HKLM\Software\Tencent\QQMusic" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\Components" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Tencent\QQMusic" /f /reg:32 >NUL 2>NUL

reg delete "HKCU\Software\Classes\.mflac" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.mgg" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmc0" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmc2" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmc3" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmc4" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmc6" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmc8" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qmcflac" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.qsc3" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.tkm" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.mflac" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.mgg" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmc0" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmc2" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmc3" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmc4" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmc6" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmc8" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qmcflac" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.qsc3" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\QQMusic.tkm" /f >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Classes\.mflac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.mgg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmc0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmc2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmc3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmc4" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmc6" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmc8" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qmcflac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.qsc3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.tkm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Applications\DiagTools.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Applications\QQMusicUninst.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.mflac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.mgg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmc0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmc2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmc3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmc4" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmc6" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmc8" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qmcflac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.qsc3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\QQMusic.tkm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" /v "QQMusic.exe" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" /v "QQMusicIE.exe" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_NAVIGATION_SOUNDS" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Internet Explorer\ProtocolExecute\tencent" /f >NUL 2>NUL

ECHO.&ECHO Done.
ECHO.&ECHO Modded  by www.423down.com

for %%a in (C D E F G H I G K L M N O P Q R S T U V W X Y Z) do rd /s/q "%%a:\QQMusicCache" >NUL 2>NUL
PUSHD .. & RD /S/Q "%~DP0" >NUL 2>NUL
