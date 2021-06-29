@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

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
::rd/s/q "%CommonProgramFiles(x86)%\Adobe\OOBE"2>NUL
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

::删除AI桌面和开始菜单快捷方式
del/q "Adobe Illustrator 2021.lnk" >NUL 2>NUL
del/q "%Public%\Desktop\Adobe Illustrator 2021.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\Adobe Illustrator 2021.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\Adobe Illustrator 2021"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Adobe Illustrator 2021"2>NUL

::删除Illustrator产品注册表键值
reg delete "HKCU\SOFTWARE\Classes\.ai" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Adobe\CSXS.10" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Adobe\CommonFiles\CRLog" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Adobe\Illustrator 2021" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Adobe\Illustrator 2020" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.pcx\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.pdd\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.psd\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.pxr\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.tga\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.tif\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\.tiff\OpenWithList\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Illustrator" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Illustrator" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\RuntimeExceptionHelperModules" /f /v "%~dp0Support Files\Contents\Windows\CRClient.dll" >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Classes\.ai" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\{E0C71512-BEE9-4319-A1FF-3CD2DE74EA4A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\adbai" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Action" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.ColorBook" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.ColorSettings" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Dictionary" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.dwg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.dxf" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.EPS" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Filter" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Hyphen" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.idea" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.pict" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Plugin" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.SwatchExchange" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Template" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Illustrator.Tsume" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Adobe.Photoshop.Plugin" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Applications\Illustrator.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\auphd" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{01381564-06F4-41F7-A1DE-CC47C2BCA59C}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{06F22A18-E2DB-4E18-920F-3640A313C5E9}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{1563CB18-EE3B-4534-8441-7A7893D92E3A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{173E3D40-B777-4922-B9F8-EF4DB3C157F6}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{1C870BA1-9416-49DA-8295-205A50C3C0D1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{1F6ACC71-4D6C-4DDC-9318-E25D086DF7C1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{1F74B3CA-DF29-4B69-9F95-B2935480D777}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{28A072A1-343B-4071-BEDC-C9A33F901D7D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{2BBA3495-5244-46CE-8E84-CB0CC1B2374A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{34834A61-6D98-431D-B296-F09C3093CD6F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{34A80F91-9BD1-4B28-B0F7-5B328344BE13}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{379F392F-6204-4BA7-B0ED-2F29C5A47249}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{3F0A136F-C0DA-4DC5-8AFA-A0A89F72817F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{4598B50D-CF01-4F98-9221-B85BA0AE7887}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{45F97852-DAC7-4DAE-A3C1-1FC5CFAE7B91}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{4879FC74-7918-4460-AB9E-7E732FFB33C3}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{48F2D380-582A-44FF-BDA3-1F5C10749F1A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{5178E0B8-5BB2-4377-BF67-370AE1C1BC0E}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{525A4B16-35CB-4D09-92EC-A267F0E487E5}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{53E516C2-88DA-4306-AE2F-94F82141A3A6}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{576F86EF-A90D-4A3B-A9F2-27971C690185}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{59685A8C-0420-431A-94B2-3C703AB0CCCB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{5E018E7D-FFB0-419B-921C-8C3C7B1D2266}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{61961433-502B-4D9B-B01F-4F9104743D61}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{6B43D877-331F-417D-BED7-4DFC63BC8731}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{6E8DB625-6B40-4F7F-BD15-CD11A533FEB9}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{738D4586-927F-40E9-9199-AC0E2A38AF52}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{76172D0E-AEFD-4B3F-903E-EAF3D20E8BE7}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7710CBD8-E89B-429D-8F5C-E2A9B5872311}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7BB47D53-1D11-49D1-9D16-0A13715404ED}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7BDE49ED-2E43-4B6C-897D-53D1D8DD5780C}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7CACE1D4-C629-4A43-8E45-800FB2B00015}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7D014CE6-4934-4A50-914A-7729247C44DF}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7E461A8C-5364-4955-8305-CFAB26BC62CE}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7E68869C-09F1-469C-8BC8-CB129FC79154}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7FE48456-9E59-4A68-A574-22C94B55B63D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{90175CE6-BC0D-4AE1-96DC-37D5C5D03CEE}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9D0E34B1-BAFB-4D3B-B151-3D773ED3E5C9}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9DE071CE-5D95-4780-844A-2F481D18AE10}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9EC38D7B-DE50-4D9F-93F0-2B7905990AB3}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A58534E1-AE76-4F4E-89F6-D7FF62505CED}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A5DC83A1-159D-43D2-85B9-A7F842DCA33D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A6BDC2E0-63C7-4324-9F02-51AE4DB823D6}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{B3ED0A49-88C1-4404-904B-707BA58F4DB8}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{B6381ED3-F3A1-4172-8E92-37C4B89B3A91}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{B717942D-F0B8-4CB4-955A-54A086AD9AE3}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{B93B4F70-262D-4E9E-BD7B-EF181865B55A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{BD4A1F56-EA22-49AB-BA49-97C4097F0EC5}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{BE34C114-16A6-409E-9B36-EC98EE8FE1D65}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{BE3EF991-8616-48B5-95E0-E5425D89521A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{C16A80DC-321B-48C8-8999-F3FEB3505B53}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{C3E5C6C3-1781-44FB-A5DB-DC8FCA4BB87B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{D5FA1579-068F-4CE7-8A73-06DD760E5B75}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{DDB16B7D-1D9D-441C-8B52-D3435C5FAEF1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{DE11E0DD-668F-4888-8953-B6D7E37C022F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E0C71512-BEE9-4319-A1FF-3CD2DE74EA4A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E32FA349-64BE-4FC7-B8D3-D05AE797EFA2}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E831E5A3-6F71-461A-95C1-50812357F50C}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{FF694F01-24E9-4874-97C1-77108F71E7DB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\FileType\{E0C71512-BEE9-4319-A1FF-3CD2DE74EA4A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.AIPreviewHandler" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Application" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Application.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Artwork" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.CMYKColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.CMYKColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.DocumentPreset" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.DocumentPreset.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.EPSSaveOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.EPSSaveOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensItemToExport" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensItemToExport.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsJPEG" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsJPEG.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsPNG24" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsPNG24.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsPNG8" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsPNG8.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsWebOptimizedSVG" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensOptionsWebOptimizedSVG.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensPDFOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportForScreensPDFOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsAutoCAD" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsAutoCAD.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsFlash" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsFlash.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsGIF" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsGIF.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsJPEG" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsJPEG.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsPhotoshop" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsPhotoshop.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsPNG24" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsPNG24.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsPNG8" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsPNG8.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsSVG" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsSVG.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsTIFF" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsTIFF.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsWebOptimizedSVG" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ExportOptionsWebOptimizedSVG.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.FXGSaveOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.FXGSaveOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.GradientColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.GradientColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.GrayColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.GrayColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.IllustratorSaveOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.IllustratorSaveOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ImageCaptureOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ImageCaptureOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Ink" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Ink.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.InkInfo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.InkInfo.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.LabColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.LabColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Matrix" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Matrix.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.NoColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.NoColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.OpenOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.OpenOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Paper" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Paper.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PaperInfo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PaperInfo.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PatternColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PatternColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PDFSaveOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PDFSaveOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PPDFile" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PPDFile.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PPDFileInfo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PPDFileInfo.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintColorManagementOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintColorManagementOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintColorSeparationOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintColorSeparationOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintCoordinateOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintCoordinateOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Printer" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Printer.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrinterInfo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrinterInfo.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintFlattenerOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintFlattenerOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintFontOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintFontOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintJobOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintJobOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintPageMarksOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintPageMarksOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintPaperOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintPaperOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintPostScriptOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.PrintPostScriptOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.RasterEffectOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.RasterEffectOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.RasterizeOptions" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.RasterizeOptions.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.RGBColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.RGBColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Screen" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.Screen.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ScreenInfo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ScreenInfo.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ScreenSpotFunction" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.ScreenSpotFunction.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.SpotColor" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.SpotColor.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.TabStopInfo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Illustrator.TabStopInfo.25" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{091adaf8-d422-11db-8314-0800200c9a66}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{0b10e85e-04d1-491e-895c-6eb5d2093515}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{0e3bf58b-a0f2-4776-9cd0-279fcb26009e}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{0e9e7b8c-bf29-4a10-9b1c-9f292fdab07a}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{196f9f57-2023-4c2f-8662-9c20f9d6de7a}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{1BD449AE-95C1-496B-9BDD-32AEB30CA819}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{20899c07-06f0-4803-bd2a-4059f9764852}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{20899c08-06f0-4803-bd2a-4059f9764852}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{246086f4-6f43-4d2b-a0ba-3bfb0e484ddf}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{255cd590-0fbf-4345-94f5-871c4021d6bf}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2A8F3C5F-B4E3-45bb-89CB-93F062B4F9F1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2d2a6b70-ea28-49aa-b7c0-3eec671cbacc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{30557e1d-a243-499d-84b8-6e170b36a1bd}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{3cc63f1c-ea9c-4636-a16c-63808c42691e}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4028B58C-1543-4B0B-A73B-4783B12BD760}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78df9f-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78df9f-7a09-11d4-81a0-00c04f60ecce}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfa2-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfa5-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfa8-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfab-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfb4-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfb7-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfba-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfbd-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfc0-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfc0-7a09-11d4-81a0-00c04f60eccd}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfc0-7a09-11d4-81a0-00c04f60ecce}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfc3-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfc6-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfc9-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfcc-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfcd-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfce-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfe6-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfe7-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfe8-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfe9-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4c78dfeb-7a09-11d4-81a0-00c04f60eccc}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{500c9af9-aa54-4941-b544-132e4d285938}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{558ef46f-a352-4a0d-9b1c-a2f6118fe611}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{561231EA-87C6-4F37-B8A0-053CAE2AB706}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{57EDB0EB-8F86-4898-AA88-5D6F47DEE239}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{60e764bb-cbee-421f-b706-d228072ebb89}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{713F68D4-459C-4229-AB12-526A71A19698}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{75482e9d-b225-419a-8187-ee9eb424138e}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{7c1fa60d-bf8f-4c43-b14c-77d842034966}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{8507c961-de07-440e-a2d8-6d48247abf79}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{9157f2b0-d436-4ac6-9769-94dc89e6ec92}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20a7-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20a8-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20a9-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20aa-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ab-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ac-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ad-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ae-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20af-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b1-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b2-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b3-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b4-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b5-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b6-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b7-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b8-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20b9-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ba-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20bb-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20bc-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20be-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20bf-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c0-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c1-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c2-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c3-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c4-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c5-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c6-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c8-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20c9-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ca-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20cb-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20cc-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20cd-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20cf-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20d0-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20d5-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20d6-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20d7-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20d8-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20d9-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20da-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20db-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20dc-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20dd-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20de-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20df-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e0-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e1-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e2-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e3-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e7-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e8-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20e9-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ea-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20eb-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ec-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ed-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ee-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20ef-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd20f0-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c00-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c01-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c02-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c03-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c04-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c05-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c06-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c07-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c08-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c09-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c0a-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c0b-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c0c-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c0d-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c0e-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c0f-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c10-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c11-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c12-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c14-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{95cd2c15-ad72-11d3-b086-0010a4f5c335}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{97DDAA0B-4235-4E6F-B13C-FE850F759964}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{A07B43A9-0201-4369-A1B5-8A33C8A0BB23}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{ad25a97a-80bc-4d6a-9e61-7e288de977ca}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{ad865867-ded8-42d6-9bd8-d77533905975}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{b1607d7c-2ea8-41b0-977a-f5b0a36df932}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DB10BDB0-CC74-49DC-B9C6-8069AF4765BB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{e380aaf5-61bf-44c2-b3d2-00d631ce879d}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{f0692236-a49a-474d-9745-715426856760}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{fc0a0bd3-5ffb-4301-a44f-f5b3ed181224}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{32307797-1F1D-4501-8F73-163F0AB321E0}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{C3D06A66-549F-4B75-BC44-93A66FBB367D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\FileType\{C3D06A66-549F-4B75-BC44-93A66FBB367D}" /f >NUL 2>NUL
ASSOC .=. >NUL 2>NUL

CLS&ECHO.&ECHO 完成