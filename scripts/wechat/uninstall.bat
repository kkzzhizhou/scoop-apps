@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im WeChat* /t >NUL 2>NUL
taskkill /f /im xwalk_service.exe >NUL 2>NUL

rd/s/q "%Temp%\WeChatSetup"2>NUL
rd/s/q "%Temp%\WeChatUninst"2>NUL
rd/s/q "%AppData%\Tencent\WeChat"2>NUL

ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL&&(
del/q "%Public%\Desktop\微信.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\微信.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\腾讯软件\微信"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\腾讯软件\微信"2>NUL
rd/s/q "%localappdata%\Tencent\BrowsingService"2>NUL
)
ver|findstr "5\.[0-9]\.[0-9][0-9]*" >NUL&&(
del/q "%UserProfile%\桌面\腾讯软件\微信.lnk" >NUL 2>NUL
del/q "%AllUsersProfile%\桌面\腾讯软件\微信.lnk" >NUL 2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\腾讯软件\微信" 2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\腾讯软件\微信" 2>NUL
rd/s/q "%UserProfile%\Local Settings\Application Data\Tencent\BrowsingService"2>NUL
)
reg delete "HKCU\Software\Tencent\WeChat" /f>NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WeChat" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WeChat" /f /reg:32 >NUL 2>NUL
