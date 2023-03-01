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
del/f/s/q "%temp%\kuwo*" >NUL 2>NUL
del/f/s/q "%temp%\KwBindApp*" >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "kwmusic" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "kwmusic" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\\Microsoft\Windows\CurrentVersion\Run" /f /v "kwmusic" /reg:32 >NUL 2>NUL

ver|findstr "5\.[0-9]\.[0-9][0-9]*" >NUL && (
rd /s/q "%AllUsersProfile%\Application Data\kuwodata\kwshow" 2>NUL
rd /s/q "%AllUsersProfile%\Application Data\kuwodata\kwmusic2013\Update" 2>NUL
del/f/q "%AllUsersProfile%\Application Data\kuwodata\kwmusic2013\ModuleData\ModMusicTool\conf.txt" >NUL 2>NUL
md "%AllUsersProfile%\Application Data\kuwodata\kwmusic2013\ModuleData\ModMusicTool" 2>NUL
echo f|copy /y "Bin\Data\conf.txt" "%AllUsersProfile%\Application Data\kuwodata\kwmusic2013\ModuleData\ModMusicTool" >NUL 2>NUL
attrib +r "%AllUsersProfile%\Application Data\kuwodata\kwmusic2013\ModuleData\ModMusicTool\conf.txt" 2>NUL
echo. >"%AllUsersProfile%\Application Data\kuwodata\kwmusic2013\Update" 2>NUL
echo. >"%AllUsersProfile%\Application Data\kuwodata\kwshow" 2>NUL
)

ver|findstr "\<6\.[0-9]\.[0-9][0-9]*\> \<10\.[0-9]\.[0-9][0-9]*\>" >NUL && (
rd /s/q "%ProgramData%\kuwodata\kwshow" 2>NUL
rd /s/q "%ProgramData%\kuwodata\kwmusic2013\Update" 2>NUL
del/f/q "%ProgramData%\kuwodata\kwmusic2013\ModuleData\ModMusicTool\conf.txt" >NUL 2>NUL
md "%ProgramData%\Kuwodata\kwmusic2013\ModuleData\ModMusicTool" 2>NUL
echo f|copy /y "Bin\Data\conf.txt" "%ProgramData%\Kuwodata\kwmusic2013\ModuleData\ModMusicTool" >NUL 2>NUL
echo. >"%ProgramData%\kuwodata\kwmusic2013\Update" 2>NUL
echo. >"%ProgramData%\kuwodata\kwshow" 2>NUL
)

CLS
ECHO.&ECHO 完成
ECHO.&ECHO Modded by www.423down.com
