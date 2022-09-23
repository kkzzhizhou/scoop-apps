@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im KwW* >NUL 2>NUL
taskkill /f /im KwMusic* >NUL 2>NUL
taskkill /f /im KwWebKit*  >NUL 2>NUL
taskkill /f /im KwService* >NUL 2>NUL
taskkill /f /im runshelldraw* >NUL 2>NUL
taskkill /f /im WriteMbox.exe >NUL 2>NUL
taskkill /f /im KwKnowSong.exe >NUL 2>NUL

rd/s/q "%temp%\KWMUSIC" 2>NUL
rd/s/q "%AppData%\kuwodata" 2>NUL
rd/s/q "%LocalAppData%\kwmusic" 2>NUL
ver|findstr "5\.[0-9]\.[0-9][0-9]*" >NUL && (
rd/s/q "%AllUsersProfile%\Application Data\Kuwodata" 2>NUL
rd/s/q "%UserProfile%\Local Settings\Application Data\kwmusic" 2>NUL
del/q "%UserProfile%\桌面\酷我音乐.lnk" >NUL 2>NUL
del/q "%AllUsersProfile%\桌面\酷我音乐.lnk" >NUL 2>NUL
rd/s/q "%UserProfile%\「开始」菜单\程序\酷我音乐"2>NUL
rd/s/q "%AllUsersProfile%\「开始」菜单\程序\酷我音乐"2>NUL
)
ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL && (
rd/s/q "%ProgramData%\kuwodata" 2>NUL
rd/s/q "%UserProfile%\AppData\Local\kwmusic" 2>NUL
del/q "%Public%\Desktop\酷我音乐.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\酷我音乐.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\酷我音乐"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\酷我音乐"2>NUL
)
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "kwmusic" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "kwmusic" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "kwmusic" /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\KwMusic" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\KwMusic" /f /reg:32 >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Classes\CLSID\{C190FFCA-1E3C-4C52-AAFF-01AD4CF394E0}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Directory\shell\kwopen" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Directory\shell\kwplaylist" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kuwo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Clients\Media\KwMusic" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Clients\Media\KwMusic" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_AAC" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_AC3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_ape" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_CDA" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_CUE" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_DFF" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_dks" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_DSF" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_FLAC" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_KWM" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_lrc" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_lrcx" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_M4A" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_MP1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_MP2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_MP3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_OGG" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_OPUS" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_TTA" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_WAV" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_wma" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\kwfile_WV" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_AAC" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_AC3" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_ape" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_CDA" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_CUE" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_DFF" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_DSF" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_FLAC" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_KWM" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_M4A" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_MP1" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_MP2" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_MP3" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_OGG" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_OPUS" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_TTA" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_WAV" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_wma" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\kwfile_WV" /f >NUL 2>NUL

for %%a in (c d e f h i j k l m n o) do rd/s/q "%%a:\KwDownload\temp"2>NUL

CLS
ECHO.&ECHO Modded by www.423down.com
