@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

::by zd423<https://www.423down.com>

taskkill /f /im Xftp* >NUL 2>NUL

::移除许可服务组件
net stop "FlexNet Licensing Service" >NUL 2>NUL
sc delete "FlexNet Licensing Service" >NUL 2>NUL
rd/s/q "%CommonProgramFiles%\Macrovision Shared"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Macrovision Shared"2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL

::清除软件相关数据
regsvr32 /s /u NsCopyHook3.dll
rd/s/q "%ProgramData%\NetSarang" 2>NUL
rd/s/q "%AllUsersProfile%\NetSarang\Xftp"2>NUL

reg delete "HKCU\Software\NetSarang\Xftp" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Xftp" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Common" /F>NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Xftp" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\NetSarang\Common" /F /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /v "%~dp0NsCopyHook3.dll" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /v "%~dp0NsCopyHook3.dll" /f /reg:32 >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Classes\.xfp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xftp.xfp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Xtransport.xts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{037DA433-DCF0-480e-9A61-DCE5F59F1F7D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Directory\shellex\CopyHookHandlers\NsCopyHookHandler3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{C65D86CD-DD0E-4D60-824B-062863FBD183}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\NsCopyHook.NsCopyHookHandler3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\NsCopyHook.NsCopyHookHandler3.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{6CA23E2A-035A-40B1-B577-C96BEEE94DB5}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{037DA433-DCF0-480E-9A61-DCE5F59F1F7D}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{C65D86CD-DD0E-4D60-824B-062863FBD183}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xftp.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{037DA433-DCF0-480e-9A61-DCE5F59F1F7D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{037DA433-DCF0-480e-9A61-DCE5F59F1F7D}" /f /reg:32 >NUL 2>NUL

reg delete "HKCR\.xfp" /f >NUL 2>NUL
reg delete "HKCR\Xftp.xfp" /f >NUL 2>NUL
reg delete "HKCR\Xtransport.xts" /f >NUL 2>NUL
reg delete "HKCR\CLSID\{037DA433-DCF0-480e-9A61-DCE5F59F1F7D}" /f >NUL 2>NUL
reg delete "HKCR\Directory\shellex\CopyHookHandlers\NsCopyHookHandler3" /f >NUL 2>NUL
reg delete "HKCR\Installer\Features\66FA67D244E68DA4194BBC5D9085E899" /f >NUL 2>NUL
reg delete "HKCR\Installer\Features\D20352A90C039D93DBF6126ECE614057" /f >NUL 2>NUL
reg delete "HKCR\Installer\Products\66FA67D244E68DA4194BBC5D9085E899" /f >NUL 2>NUL
reg delete "HKCR\Installer\Products\D20352A90C039D93DBF6126ECE614057" /f >NUL 2>NUL
reg delete "HKCR\Installer\UpgradeCodes\41A387AA3A7A33D3590FA953D1350011" /f >NUL 2>NUL
reg delete "HKCR\Installer\UpgradeCodes\4CA9A431D9AC69E49878F3FF2A3B6E67" /f >NUL 2>NUL
reg delete "HKCR\Interface\{C65D86CD-DD0E-4D60-824B-062863FBD183}" /f >NUL 2>NUL
reg delete "HKCR\NsCopyHook.NsCopyHookHandler3" /f >NUL 2>NUL
reg delete "HKCR\NsCopyHook.NsCopyHookHandler3.1" /f >NUL 2>NUL
reg delete "HKCR\TypeLib\{6CA23E2A-035A-40B1-B577-C96BEEE94DB5}" /f >NUL 2>NUL
reg delete "HKCR\CLSID\{037DA433-DCF0-480E-9A61-DCE5F59F1F7D}" /f /reg:32 >NUL 2>NUL
reg delete "HKCR\Interface\{C65D86CD-DD0E-4D60-824B-062863FBD183}" /f /reg:32 >NUL 2>NUL
reg delete "HKCR\TypeLib\{6CA23E2A-035A-40B1-B577-C96BEEE94DB5}" /f /reg:32 >NUL 2>NUL

ECHO. >NUL&EXIT
