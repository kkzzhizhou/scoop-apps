@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im ld.exe >NUL 2>NUL
taskkill /f /im aapt.exe >NUL 2>NUL
taskkill /f /im ldcam.exe >NUL 2>NUL
taskkill /f /im adb.exe /t >NUL 2>NUL
taskkill /f /im fynews.exe >NUL 2>NUL
taskkill /f /im ldnews.exe >NUL 2>NUL
taskkill /f /im dnunzip.exe >NUL 2>NUL
taskkill /f /im ldrecord.exe >NUL 2>NUL
taskkill /f /im vbox-img.exe >NUL 2>NUL
taskkill /f /im ldremote.exe >NUL 2>NUL
taskkill /f /im dnconsole.exe >NUL 2>NUL
taskkill /f /im bugreport.exe >NUL 2>NUL
taskkill /f /im ldconsole.exe >NUL 2>NUL
taskkill /f /im LdBoxSVC.exe /t >NUL 2>NUL
taskkill /f /im dnplayer.exe /t >NUL 2>NUL
taskkill /f /im driverconfig.exe >NUL 2>NUL
taskkill /f /im LdVBoxSVC.exe /t >NUL 2>NUL
taskkill /f /im dnrepairer.exe /t >NUL 2>NUL
taskkill /f /im VBoxManage.exe /t >NUL 2>NUL
taskkill /f /im VirtualBox.exe /t >NUL 2>NUL
taskkill /f /im LdVirtualBox.exe /t >NUL 2>NUL
taskkill /f /im dnmultiplayer.exe /t >NUL 2>NUL
taskkill /f /im LdVBoxHeadless.exe /t >NUL 2>NUL
taskkill /f /im vmware-vdiskmanager.exe >NUL 2>NUL

::标记软件路径检测键值
reg add "HKCU\SOFTWARE\leidian\ldplayer9" /f /v "DataDir" /d "%~dp0vms\" >NUL 2>NUL
reg add "HKCU\SOFTWARE\leidian\ldplayer9" /f /v "InstallDir" /d "%~dp0\" >NUL 2>NUL

::安装模拟器内核VirtualBox
IF NOT EXIST "%ProgramW6432%" (
ECHO.&ECHO 稍等，正在安装模拟器内核..
start /wait dnrepairer.exe -RegServer
) ELSE (
ECHO.&ECHO 稍等，正在安装模拟器内核...
start /wait dnrepairer.exe -RegServer
)

::清除安装残留的开机启动项
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "LDNews" >NUL 2>NUL
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "ldremote" >NUL 2>NUL

ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT