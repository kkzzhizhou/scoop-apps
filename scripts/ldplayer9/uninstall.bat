@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

ECHO.&ECHO Uninstalling, please wait...
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

::Uninstall VirtualBox kernel components
sc stop LdVKbd >NUL 2>NUL&sc delete LdVKbd >NUL 2>NUL
sc stop LdVMou >NUL 2>NUL&sc delete LdVMou >NUL 2>NUL
sc stop Ld9BoxSup >NUL 2>NUL&sc delete Ld9BoxSup >NUL 2>NUL
sc stop LdScpVBus >NUL 2>NUL&sc delete LdScpVBus >NUL 2>NUL
sc stop LdRemoteSvc >NUL 2>NUL&sc delete LdRemoteSvc >NUL 2>NUL
sc stop ZegoAgentSCService >NUL 2>NUL&sc delete ZegoAgentSCService >NUL 2>NUL

IF NOT EXIST "%ProgramW6432%" (
if exist "%ProgramFiles%\ldplayer9box\Ld9BoxSVC.exe" "%ProgramFiles%\ldplayer9box\Ld9BoxSVC.exe" /UnRegServer
if exist "%ProgramFiles%\ldplayer9box\VBoxC.dll" regsvr32 /s /u "%ProgramFiles%\ldplayer9box\VBoxC.dll"
if exist "%ProgramFiles%\ldplayer9box\VBoxProxyStub.dll" regsvr32 /s /u "%ProgramFiles%\ldplayer9box\VBoxProxyStub.dll"
if exist "%ProgramFiles%\ldplayer9box\x86\VBoxClient-x86.dll" regsvr32 /s /u "%ProgramFiles%\ldplayer9box\x86\VBoxClient-x86.dll"
if exist "%ProgramFiles%\ldplayer9box\x86\VBoxProxyStub-x86.dll" regsvr32 /s /u "%ProgramFiles%\ldplayer9box\x86\VBoxProxyStub-x86.dll"
if exist "%ProgramFiles%\ldplayer9box" rd/s/q "%ProgramFiles%\ldplayer9box" 2>NUL
) ELSE (
if exist "%ProgramW6432%\ldplayer9box\Ld9BoxSVC.exe" "%ProgramW6432%\ldplayer9box\Ld9BoxSVC.exe" /UnRegServer
if exist "%ProgramW6432%\ldplayer9box\VBoxC.dll" regsvr32 /s /u "%ProgramW6432%\ldplayer9box\VBoxC.dll"
if exist "%ProgramW6432%\ldplayer9box\VBoxProxyStub.dll" regsvr32 /s /u "%ProgramW6432%\ldplayer9box\VBoxProxyStub.dll"
if exist "%ProgramW6432%\ldplayer9box\x86\VBoxClient-x86.dll" regsvr32 /s /u "%ProgramW6432%\ldplayer9box\x86\VBoxClient-x86.dll"
if exist "%ProgramW6432%\ldplayer9box\x86\VBoxProxyStub-x86.dll" regsvr32 /s /u "%ProgramW6432%\ldplayer9box\x86\VBoxProxyStub-x86.dll"
if exist "%ProgramW6432%\ldplayer9box" rd/s/q "%ProgramW6432%\ldplayer9box" 2>NUL
)

::Clear system related residual data
rd/s/q "C:\ChangZhi" 2>NUL
rd/s/q "%AppData%\changzhi2" 2>NUL
rd/s/q "%AppData%\XuanZhi" 2>NUL
rd/s/q "%AppData%\XuanZhi9" 2>NUL
rd/s/q "%AppData%\lddownloader" 2>NUL
rd/s/q "%ProgramData%\obs-studio-hook" 2>NUL
rd/s/q "%UserProfile%\.Ld2VirtualBox" 2>NUL
del /q "%AppData%\changzhi_leidian.data" >NUL 2>NUL
del/f/q "%WinDir%\System32\drivers\LdVMou.sys" >NUL 2>NUL
del/f/q "%WinDir%\System32\drivers\LdVKbd.sys" >NUL 2>NUL
del/f/q "%WinDir%\System32\drivers\LdScpVBus.sys" >NUL 2>NUL
if exist "%WinDir%\System32\WdfCoInstaller01009.dll" takeown /f "%WinDir%\System32\WdfCoInstaller01009.dll" /a >NUL 2>NUL
if exist "%WinDir%\System32\WdfCoInstaller01009.dll" echo y|icacls "%WinDir%\System32\WdfCoInstaller01009.dll" /c /grant "Everyone:f" >NUL 2>NUL
del /f /q "%WinDir%\System32\WdfCoInstaller01009.dll" >NUL 2>NUL
takeown /f "%WinDir%\System32\DriverStore\FileRepository\ldvkbd.inf_amd64_ae5a64c7e0d5232d\*" /a /r /d y >NUL 2>NUL
takeown /f "%WinDir%\System32\DriverStore\FileRepository\ldvmou.inf_amd64_ed17807b03d15bc9\*" /a /r /d y >NUL 2>NUL
takeown /f "%WinDir%\System32\DriverStore\FileRepository\ldscpvbus.inf_amd64_623ff10be9719b7b\*" /a /r /d y >NUL 2>NUL
echo y|icacls "%WinDir%\System32\DriverStore\FileRepository\ldvkbd.inf_amd64_ae5a64c7e0d5232d\*" /t /c /grant "Everyone:f" >NUL 2>NUL
echo y|icacls "%WinDir%\System32\DriverStore\FileRepository\ldvmou.inf_amd64_ed17807b03d15bc9\*" /t /c /grant "Everyone:f" >NUL 2>NUL
echo y|icacls "%WinDir%\System32\DriverStore\FileRepository\ldscpvbus.inf_amd64_623ff10be9719b7b\*" /t /c /grant "Everyone:f" >NUL 2>NUL
rd /s /q "%WinDir%\System32\DriverStore\FileRepository\ldvkbd.inf_amd64_ae5a64c7e0d5232d" 2>NUL
rd /s /q "%WinDir%\System32\DriverStore\FileRepository\ldvmou.inf_amd64_ed17807b03d15bc9" 2>NUL
rd /s /q "%WinDir%\System32\DriverStore\FileRepository\ldscpvbus.inf_amd64_623ff10be9719b7b" 2>NUL

::Clear desktop and start menu shortcuts
del/q "%Public%\Desktop\LDPlayer9.lnk" >NUL 2>NUL
del/q "%Public%\Desktop\LDMultiPlayer9.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\LDPlayer9.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\LDMultiPlayer9.lnk" >NUL 2>NUL
del/q "%AppData%\Microsoft\Windows\Start Menu\LDPlayer9.lnk" >NUL 2>NUL
del/q "%AppData%\Microsoft\Windows\Start Menu\LDMultiPlayer9.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\LDPlayer9"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\LDPlayer9"2>NUL

::Clear related registry keys
reg delete "HKCU\Software\leidian\ldremote" /f >NUL 2>NUL
reg delete "HKCU\Software\leidian\ldplayer9" /f >NUL 2>NUL
reg delete "HKCU\Software\ChangZhi2" /f >NUL 2>NUL
reg delete "HKLM\Software\leidian\ldremote" /f >NUL 2>NUL
reg delete "HKLM\Software\leidian\ldplayer9" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.ldbk" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\ldmnq.apk" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\ldmnq.ldbk" /f >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\.apk" /f /ve /d "" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.xapk" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Khronos" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Khronos" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\ESENT\Process\LdBoxSVC" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\ESENT\Process\LdBoxHeadless" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LdScpVBus" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LdVKbd" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LdVMou" /f >NUL 2>NUL
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "LDNews" >NUL 2>NUL
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "ldremote" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\leidian9" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\leidian9" /f /reg:32 >NUL 2>NUL

::Supplementary cycle cleaning system residual files
del /f /q "%WinDir%\System32\drivers\LdScpVBus.sys" >NUL 2>NUL
del /f /q "%WinDir%\System32\WdfCoInstaller01009.dll" >NUL 2>NUL
rd /s /q "%WinDir%\System32\DriverStore\FileRepository\ldvkbd.inf_amd64_ae5a64c7e0d5232d" 2>NUL
rd /s /q "%WinDir%\System32\DriverStore\FileRepository\ldvmou.inf_amd64_ed17807b03d15bc9" 2>NUL
rd /s /q "%WinDir%\System32\DriverStore\FileRepository\ldscpvbus.inf_amd64_623ff10be9719b7b" 2>NUL
rd /s /q "%AppData%\leidian9" 2>NUL

CLS
ECHO.&ECHO Clear complete, confirm deletion£¿
ECHO.&ECHO [1]Remove software but keep user data
ECHO.&ECHO [2]Remove software and user data

CHOICE /C 12 /N >NUL 2>NUL

IF "%ERRORLEVEL%"=="2" (
FOR /F "skip=2 tokens=3 " %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v personal') do (
FOR /F "delims=*" %%j in ('echo %%i') do rd/s/q "%%j\leidian9" >NUL 2>NUL)
PUSHD .. & RD /S/Q "%~DP0" >NUL 2>NUL)

IF "%ERRORLEVEL%"=="1" (
  IF EXIST "vms" (
  FOR /F "delims=*" %%a IN ('dir /a/b *.*^|findstr /i/v "vms$"') DO (
  RD /S/Q "%%a" >NUL 2>NUL & DEL /F/Q "%%a" >NUL 2>NUL)
  ) ELSE (
  PUSHD .. & RD /S/Q "%~DP0" >NUL 2>NUL))