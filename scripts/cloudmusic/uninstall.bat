@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im cloudmusic* /t >NUL 2>NUL

ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL&&(
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\网易云音乐"2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\网易云音乐"2>NUL
del /q "%UserProfile%\Desktop\网易云音乐.lnk" >NUL 2>NUL
del /q "%Public%\Desktop\网易云音乐.lnk" >NUL 2>NUL
rd/s/q "%ProgramData%\NetEaseWinDA2"2>NUL
rd/s/q "%LocalAppData%\Netease"2>NUL)

ver|findstr "5\.[0-9]\.[0-9][0-9]*" >NUL&&(
rd/s/q "%UserProfile%\Local Settings\Application Data\Netease"2>NUL
rd/s/q "%AllUsersProfile%\Application Data\NetEaseWinDA2"2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\网易云音乐" 2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\网易云音乐" 2>NUL
del /q "%AllUsersProfile%\桌面\网易云音乐.lnk" >NUL 2>NUL
del /q "%UserProfile%\桌面\网易云音乐.lnk" >NUL 2>NUL
)

reg delete "HKLM\SOFTWARE\Netease" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Netease" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\cloudmusic" /f  >NUL 2>NUL
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "cloudmusic" >NUL 2>NUL
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "cloudmusic" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\cloudmusic.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CloudMusic" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CloudMusic" /f /reg:32 >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Classes\cloudmusic.aac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.ape" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.cda" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.cue" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.flac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.m4a" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.mp3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.ncm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.ogg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.wav" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\cloudmusic.wma" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\orpheus" /f >NUL 2>NUL

CLS
ECHO.&ECHO 423down.com

IF EXIST "Netease" (
  FOR /F "delims=*" %%a IN ('dir /a/b *.*^|findstr /v /i "Netease$"') DO (
  RD /S/Q "%%a" 2>NUL & DEL /F/Q "%%a" >NUL 2>NUL)
  ) ELSE (
  PUSHD .. & RD /S/Q "%~DP0" >NUL 2>NUL)

CLS
ECHO.&ECHO 完成
ECHO.&ECHO Modded by www.423down.com
