@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

::by zd423<https://www.423down.com>

taskkill /f /im Xshell* >NUL 2>NUL
taskkill /f /im FNPLicensingService* >NUL 2>NUL

::删许可证服务组件
net stop "FlexNet Licensing Service" >NUL 2>NUL
sc delete "FlexNet Licensing Service" >NUL 2>NUL
rd/s/q "%CommonProgramFiles%\Macrovision Shared"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Macrovision Shared"2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL
reg delete "HKCU\Software\Microsoft\NetLicense" /F>NUL 2>NUL

::关联会话文件格式
reg delete "HKCR\.xsh" /f >NUL 2>NUL
reg delete "HKCR\.xts" /f >NUL 2>NUL
reg delete "HKCR\Xshell.xsh" /f >NUL 2>NUL
reg delete "HKCR\Xtransport.xts" /f >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\.xsh" /f /ve /d "Xshell.xsh" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\.xts" /f /ve /d "Xtransport.xts" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\Xshell.xsh" /f /ve /d "Xshell session" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\Xshell.xsh\DefaultIcon" /f /ve /d "%~dp0Xshell.exe,0" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\Xshell.xsh\shell\open\command" /f /ve /d "\"%~dp0Xshell.exe\" \"%%1\"" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\Xtransport.xts\shell\open" /f /ve /d "" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Classes\Xtransport.xts\shell\open\command" /f /ve /d "\"%~dp0Xtransport.exe\" -f \"%%1\"" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xagent.exe" /f /ve /d "%~dp0Xagent.exe" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Xshell.exe" /f /ve /d "%~dp0Xshell.exe" >NUL 2>NUL
::刷新会话格式图标
ASSOC .=. >NUL 2>NUL

IF NOT EXIST "%ProgramW6432%" (
::标记软件所在路径
reg add "HKLM\SOFTWARE\NetSarang\Xshell\7" /f /v "Path" /d "%~dp0\" >NUL 2>NUL
::关于显示版本号（如无该键值关于对话框则不显示版本号）
reg add "HKLM\SOFTWARE\NetSarang\Xshell\7" /f /v "Version" /d "7.0.0090" >NUL 2>NUL
::必要产品检测信息（如果不存这二进制数据在则启动失败）
reg add "HKLM\SOFTWARE\NetSarang\Xshell\7" /f /v "MagicCode" /t REG_BINARY /d "f0fd7f4d6ab3300cb5717151efd35618e4070b001100" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /f /v "%~dp0XshellCore.tlb">NUL 2>NUL
) ELSE (
reg add "HKLM\SOFTWARE\NetSarang\Xshell\7" /f /v "Path" /d "%~dp0\" /reg:32 >NUL 2>NUL
reg add "HKLM\SOFTWARE\NetSarang\Xshell\7" /f /v "Version" /d "7.0.0090" /reg:32 >NUL 2>NUL
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls" /f /v "%~dp0XshellCore.tlb" /reg:32 >NUL 2>NUL
reg add "HKLM\SOFTWARE\NetSarang\Xshell\7" /f /v "MagicCode" /t REG_BINARY /d "f0fd7f4d6ab3300cb5717151efd35618e4070b001100" /reg:32 >NUL 2>NUL
)

ECHO. >NUL&EXIT
