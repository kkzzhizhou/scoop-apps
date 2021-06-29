@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

::不是Windows 10就给提示执行退出
ver|findstr "10\.[0-9]\.[0-9][0-9]*" >NUL || (
ECHO.&ECHO AI2021最低系统要求：Windows 8, Windows 10 &TIMEOUT /t 3 >NUL&EXIT)
::不支持32位系统给出提示执行退出
IF NOT EXIST "%ProgramW6432%" (
ECHO.&ECHO 不支持当前系统，Adobe产品2020无32位版本 &TIMEOUT /t 3 >NUL&EXIT)

ECHO.&ECHO 稍等...
::结束Adobe产品全部进程
taskkill /F /IM armsvc.exe >NUL 2>NUL
taskkill /F /IM AcroTray.exe >NUL 2>NUL
taskkill /F /IM AGSService.exe >NUL 2>NUL
taskkill /F /IM AGMService.exe >NUL 2>NUL
taskkill /f /IM AEGPUSniffer.exe >NUL 2>NUL
taskkill /f /IM AnywhereEncoder* >NUL 2>NUL
taskkill /f /IM AdobeIPCBroker*  >NUL 2>NUL
taskkill /f /IM AdobeUpdateService.exe >NUL 2>NUL
taskkill /f /IM CoreSyncCustomHook.exe >NUL 2>NUL
taskkill /f /IM "Adobe CEF Helper.exe" >NUL 2>NUL
taskkill /f /IM "Adobe Update Helper.exe" >NUL 2>NUL
taskkill /f /IM "Adobe Desktop Service.exe" >NUL 2>NUL
taskkill /f /IM "adobe_licensing_helper.exe" >NUL 2>NUL
taskkill /f /IM "Adobe Spaces Helper.exe" >NUL 2>NUL
taskkill /f /IM CRWindowsClientService.exe >NUL 2>NUL
taskkill /f /IM CoreSync.exe >NUL 2>NUL
taskkill /f /IM CCLibrary.exe >NUL 2>NUL
taskkill /f /IM CCXProcess.exe >NUL 2>NUL
taskkill /f /IM "Creative Cloud.exe" >NUL 2>NUL
taskkill /f /IM CEPHtmlEngine.exe >NUL 2>NUL
taskkill /f /IM GPUSniffer.exe >NUL 2>NUL
taskkill /F /IM AISniffer.exe >NUL 2>NUL
taskkill /F /IM sniffer.exe >NUL 2>NUL
taskkill /f /IM LogTransport2.exe >NUL 2>NUL
taskkill /f /IM ImporterREDServer.exe >NUL 2>NUL
taskkill /f /IM dvaaudiofilterscan.exe >NUL 2>NUL
taskkill /f /IM dynamiclinkmanager.exe >NUL 2>NUL
taskkill /f /IM ImporterREDServer.exe >NUL 2>NUL
taskkill /f /IM Illustrator.exe >NUL 2>NUL

::清除Adobe产品相关开机启动项；
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "CCXProcess" >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "AdobeGCInvoker-1.0" >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "AdobeAAMUpdater-1.0" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "CCXProcess" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "AdobeGCInvoker-1.0" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "AdobeAAMUpdater-1.0" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /f /v "Adobe CCXProcess" >NUL 2>NUL
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /f /v "AdobeAAMUpdater-1.0" >NUL 2>NUL

::清除Adobe产品残留的安装信息；
rd/s/q "%AppData%\Adobe\Adobe PCD"2>NUL
rd/s/q "%ProgramData%\Adobe\Installer"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\caps"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\backup"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Installers"2>NUL

::清除Adobe产品激活信息及缓存；
rd/s/q "%AppData%\Adobe\SLData"2>NUL
rd/s/q "%AppData%\Adobe\SLStore"2>NUL
rd/s/q "%ProgramData%\Adobe\SLStore"2>NUL
rd/s/q "%ProgramData%\regid.1986-12.com.adobe"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\SLCache"2>NUL

::清除Adobe产品正版验证AAM组件
rd/s/q "%AppData%\Adobe\OOBE"2>NUL
rd/s/q "%LocalAppData%\Adobe\OOBE"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\OOBE"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\OOBE"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\AAMUpdaterInventory"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\AAMUpdaterInventory"2>NUL

::清除Adobe产品库和云同步组件
rd/s/q "%TEMP%\CreativeCloud"2>NUL
rd/s/q "%ProgramData%\Adobe Sync"2>NUL
rd/s/q "%ProgramW6432%\Adobe\Adobe Sync"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Vulcan"2>NUL
rd/s/q "%ProgramFiles(x86)%\Adobe\Adobe Sync"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Vulcan"2>NUL
rd/s/q "%AppData%\Adobe\Creative Cloud Libraries"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CoreSyncExtension"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CoreSyncExtension"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Creative Cloud Libraries"2>NUL
rd/s/q "%ProgramW6432%\Adobe\Adobe Creative Cloud Experience"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Creative Cloud Libraries"2>NUL
rd/s/q "%ProgramFiles(x86)%\Adobe\Adobe Creative Cloud Experience"2>NUL
reg delete "HKCU\SOFTWARE\Adobe\CreativeCloud" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.ccx" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\auphd" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\CloudSyncExt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CloudSyncCom.CloudSyncApp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CloudSyncCom.CloudSyncApp.1" /f >NUL 2>NUL
reg delete "HKLM\Classes\*\shellex\ContextMenuHandlers\AccExt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\AccExt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.AdobePluginInstallerAgent.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{1580B7BE-BAC5-42F8-960B-1ED59D905A46}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{2A118EB5-5797-4F5E-8B3D-F4ECBA3C98E4}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{42D38F2E-98E9-4382-B546-E24E4D6D04BB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{853B7E05-C47D-4985-909A-D0DC5C6D7303}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{AB9CF9F8-8A96-4F9D-BF21-CE85714C3A47}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{935767F7-DD8C-4649-A8A4-0C01E1E221C8}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{21D20ABF-B32D-46CD-AB6A-CBD566177A3D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{7A1355AF-958A-4360-89B1-A55ACEA38F95}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{7A1355AF-958A-4360-89B1-A55ACEA38F96}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{B0D5A632-C870-43B5-897E-5A02C13643A2}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{C4BB32F1-08B5-4206-81AA-3860A9F13DDA}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{E5C0A852-72AA-461B-AEB6-16ABF70DB218}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{F4FCF137-0EAE-4FA1-8B39-44320D24AF52}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{3956A7FA-824C-4184-871C-739C40164CAC}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{59E9A4A9-40E1-4CE6-B939-EE46EBA237C1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{21D20ABF-B32D-46CD-AB6A-CBD566177A3D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{7A1355AF-958A-4360-89B1-A55ACEA38F95}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{B0D5A632-C870-43B5-897E-5A02C13643A2}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{C4BB32F1-08B5-4206-81AA-3860A9F13DDA}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{E5C0A852-72AA-461B-AEB6-16ABF70DB218}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\Interface\{F4FCF137-0EAE-4FA1-8B39-44320D24AF52}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\Interface\{7A1355AF-958A-4360-89B1-A55ACEA38F96}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AdobePluginInstallerAgent.exe" /f >NUL 2>NUL

::清除UXP主屏幕版本迭代残留文件;
::rd/s/q "%LocalAppData%\UXP"2>NUL
::rd/s/q "%CommonProgramW6432%\Adobe\UXP"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\com.adobe.ccx.fnft-3.3.0"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\com.adobe.ccx.fnft-3.2.0"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\com.adobe.ccx.fnft-3.1.0"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\com.adobe.ccx.start-2.10.0"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\com.adobe.ccx.start-2.11.0"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_6_64"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_10_86"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_11_27"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_13_141"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_4_23"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_7_76"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_8_294"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\com.adobe.ccx.fnft-3.3.0"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\com.adobe.ccx.fnft-3.2.0"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\com.adobe.ccx.fnft-3.1.0"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\com.adobe.ccx.start-2.10.0"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\com.adobe.ccx.start-2.11.0"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_6_64"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_10_86"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_11_27"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_2_13_141"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_4_23"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_7_76"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_8_294"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_8_299"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\CEP\extensions\CC_LIBRARIES_PANEL_EXTENSION_3_9_275"2>NUL

::清除Adobe产品相关临时残留文件；
rd/s/q "%TEMP%\UXP"2>NUL
rd/s/q "%TEMP%\Adobe"2>NUL
rd/s/q "%TEMP%\Adobe Temp"2>NUL
rd/s/q "%TEMP%\cep_cache"2>NUL
rd/s/q "%TEMP%\PhotoshopCrashes"2>NUL
rd/s/q "%TEMP%\com.adobe.ae.cap"2>NUL
del /f /q "%TEMP%\AdobeIPC*" >NUL 2>NUL
del /f /q "%TEMP%\CEP*.log" >NUL 2>NUL
del /f /q "%TEMP%\NGL*" >NUL 2>NUL
del /f /q "%TEMP%\OCL*" >NUL 2>NUL

rd/s/q "%LocalAppData%\Adobe\PII"2>NUL
rd/s/q "%LocalAppData%\Adobe\Licflags"2>NUL
rd/s/q "%LocalAppData%\Adobe\TypeSupport"2>NUL
rd/s/q "%localappdata%\PeerdistRepub"2>NUL
rd/s/q "%LocalAppData%\PeerDistRepub"2>NUL
rd/s/q "%PuBlic%\Documents\AdobeInstalledCodecsTier2"2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\Linguistics"2>NUL
rd/s/q "%userprofile%\AppData\LocalLow\Adobe\Linguistics"2>NUL

rd/s/q "%AppData%\Adobe\Adobe PDF"2>NUL
rd/s/q "%AppData%\Adobe\Adobe Analysis Server"2>NUL
rd/s/q "%AppData%\Adobe\Butler"2>NUL
rd/s/q "%AppData%\Adobe\Common"2>NUL
rd/s/q "%AppData%\Adobe\CRLogs"2>NUL
rd/s/q "%AppData%\Adobe\CAHeadless"2>NUL
rd/s/q "%AppData%\Adobe\CCX Welcome"2>NUL
rd/s/q "%AppData%\Adobe\DynamicSonar"2>NUL
rd/s/q "%AppData%\Adobe\dynamiclinkmanager"2>NUL
rd/s/q "%AppData%\Adobe\DVAAudioFilterScan"2>NUL
rd/s/q "%AppData%\Adobe\DVAAudioFilterScan Lumetri"2>NUL
rd/s/q "%AppData%\Adobe\GUDE"2>NUL
rd/s/q "%AppData%\Adobe\GPUSniffer"2>NUL
rd/s/q "%AppData%\Adobe\RTTransfer"2>NUL
rd/s/q "%AppData%\Adobe\Logs"2>NUL
rd/s/q "%AppData%\Adobe\Lumetri"2>NUL
rd/s/q "%AppData%\Adobe\LensCorrection"2>NUL
rd/s/q "%AppData%\Adobe\LogTransport2CC"2>NUL
rd/s/q "%AppData%\Adobe\Optimized Colors"2>NUL
rd/s/q "%AppData%\Adobe\PseudoFontsCache"2>NUL
rd/s/q "%AppData%\Adobe\Team Projects Local Hub"2>NUL
rd/s/q "%AppData%\Adobe\Workflow"2>NUL
rd/s/q "%AppData%\Adobe\Sonar"2>NUL

rd/s/q "%CommonProgramFiles(x86)%\Adobe\AdobeApplicationManager"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Adobe PCD"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\PCF"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Starth"2>NUL

::清除Illustrator产品残留
rd/s/q "%AppData%\Adobe\UPI"2>NUL
rd/s/q "%AppData%\Adobe\AIRobin 24 Settings"2>NUL
rd/s/q "%AppData%\Adobe\AIRobin 25.0.0 Settings"2>NUL
rd/s/q "%AppData%\Adobe\Adobe Illustrator"2>NUL
rd/s/q "%AppData%\Adobe\Adobe Illustrator 24 Settings"2>NUL
rd/s/q "%AppData%\Adobe\Adobe Illustrator 25 Settings"2>NUL
del/f/s/q "%CommonProgramW6432%\Adobe\HelpCfg\Illustrator*.helpcfg" >NUL 2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Startup Scripts CC\Illustrator 2020"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Startup Scripts CC\Illustrator 2021"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Scripting Dictionaries CC\Illustrator 2020"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Scripting Dictionaries CC\Illustrator 2021"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Startup Scripts CC\Illustrator 2020"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Startup Scripts CC\Illustrator 2021"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Scripting Dictionaries CC\Illustrator 2020"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Scripting Dictionaries CC\Illustrator 2021"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Bridge 2020 Extensions\Adobe Illustrator Automation 2020"2>NUL
rd/s/q "%CommonProgramW6432%\Adobe\Bridge 2021 Extensions\Adobe Illustrator Automation 2021"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Bridge 2020 Extensions\Adobe Illustrator Automation 2020"2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Adobe\Bridge 2021 Extensions\Adobe Illustrator Automation 2021"2>NUL

::复制颜色配置、UXP主屏幕、帮助支持等文件（颜色配置文件为必要文件）
if not exist "%CommonProgramW6432%\Adobe" md "%CommonProgramW6432%\Adobe" 2>NUL
if not exist "%CommonProgramFiles(x86)%\Adobe" md "%CommonProgramFiles(x86)%\Adobe" 2>NUL
echo f|xcopy /c/e/i/h/r/y "Data\CommonProgramW6432\Adobe" "%CommonProgramW6432%\Adobe" >NUL 2>NUL
echo f|xcopy /c/e/i/h/r/y "Data\CommonProgramFiles(x86)\Adobe" "%CommonProgramFiles(x86)%\Adobe" >NUL 2>NUL


::注册产品类标识及关联文件类型
Rundll32 setupapi.dll,InstallHinfSection DefaultInstall 132 .\ProductsRegInfo.inf
ASSOC .=. >NUL 2>NUL

ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT