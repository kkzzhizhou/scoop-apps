@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

taskkill /f /im XMP.exe >NUL 2>NUL
taskkill /f /im XLLiveUD* >NUL 2>NUL
taskkill /f /im Thunder* /T >NUL 2>NUL
taskkill /f /im xlbrowsershell* >NUL 2>NUL
taskkill /f /im DownloadSDKServer* >NUL 2>NUL

::卸载IE浏览器或IE内核程序关联组件
regsvr32 /s /u BHO\ThunderAgent.dll
regsvr32 /s /u BHO\ThunderAgent64.dll
regsvr32 /s /u Program\np_tdieplat.dll
start /wait Program\Thunder.exe -unassociate:all -unregprotocol:all

::删除防火墙入站规则
netsh advfirewall firewall delete rule name="Thunder" dir=in program="%~dp0Program\Thunder.exe" >NUL 2>NUL
netsh advfirewall firewall delete rule name="DownloadSDKServer" dir=in program="%~dp0Program\resources\bin\SDK\DownloadSDKServer.exe" >NUL 2>NUL

::清除系统后台残留文件
rd/s/q "%TEMP%\Xmp"2>NUL
rd/s/q "%TEMP%\xlwfp"2>NUL
rd/s/q "%TEMP%\Xunlei"2>NUL
rd/s/q "%TEMP%\Thunder"2>NUL
rd/s/q "%TEMP%\XLLiveUD"2>NUL
rd/s/q "%TEMP%\XLNonIESvr"2>NUL
rd/s/q "%TEMP%\ThunderLiveUD"2>NUL
rd/s/q "%TEMP%\ThunderInstall"2>NUL
rd/s/q "%TEMP%\Thunder Network"2>NUL
rd/s/q "%AppData%\迅雷" 2>NUL
rd/s/q "%AppData%\迅雷X" 2>NUL
rd/s/q "%AppData%\迅雷11" 2>NUL
rd/s/q "%AppData%\thunder"2>NUL
rd/s/q "%AppData%\thunderx"2>NUL
rd/s/q "%AppData%\XLGameBox"2>NUL
rd/s/q "%AppData%\迅雷播放组件" 2>NUL
rd/s/q "%AppData%\Thunder Network"2>NUL
rd/s/q "%ProgramData%\USOShared"2>NUL
rd/s/q "%ProgramData%\USOPrivate"2>NUL
rd/s/q "%ProgramData%\Thunder Network"2>NUL
rd/s/q "%CommonProgramW6432%\Thunder Network" 2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Thunder Network"2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\XunLei"2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\XunleiBHO"2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\Thunder Network"2>NUL
del /q "%UserProfile%\AppData\APlayerCodecs3.exe" >NUL 2>NUL
del /q "%ProgramData%\APlayerCodecs3.exe" >NUL 2>NUL
rd/s/q "%PUBLIC%\Thunder Network"2>NUL
rd/s/q "%PUBLIC%\Documents\Thunder Network"2>NUL

::清除迅雷目录残留文件
del "Thunder.lnk " >NUL 2>NUL
del "Program\stat.dat" >NUL 2>NUL
del "Program\detect_stat.dat" >NUL 2>NUL
del "Program\latest_thunder_stat.xml" >NUL 2>NUL
del "Program\resources\bin\TBC\xlbrowser.ini" >NUL 2>NUL
rd /s /q "Program\resources\bin\TBC\Data"2>NUL

::清除桌面和开始菜单快捷方式
del /q "%Public%\Desktop\迅雷.lnk" >NUL 2>NUL
del /q "%UserProfile%\Desktop\迅雷.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\迅雷软件"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\迅雷软件"2>NUL
del /q "%AppData%\Microsoft\Windows\Libraries\迅雷下载.library-ms" >NUL 2>NUL

::清除注册表相关残留键值
reg delete "HKCU\Software\Thunder Network" /f >NUL 2>NUL
reg delete "HKLM\Software\Thunder Network" /f >NUL 2>NUL
reg delete "HKLM\Software\Thunder Network" /f /reg:32 >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\thunder" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\thunder" /f /reg:32 >NUL 2>NUL
reg delete "HKCU\SOFTWARE\MozillaPlugins\@xunlei.com/npxunlei;version=1.0.0.2" /f >NUL 2>NUL
reg delete "HKLM\Software\MozillaPlugins\@xunlei.com/npxunlei;version=1.0.0.2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\MozillaPlugins\@xunlei.com/npxunlei;version=1.0.0.2" /f >NUL 2>NUL
reg delete "HKLM\Software\MozillaPlugins\@xunlei.com/npxunlei;version=1.0.0.2" /f /reg:32 >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Mozilla\NativeMessagingHosts\com.xunlei.thunder" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Mozilla\NativeMessagingHosts\com.xunlei.thunder" /f >NUL 2>NUL
reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.xunlei.thunder" /f >NUL 2>NUL
reg delete "HKLM\Software\Google\Chrome\NativeMessagingHosts\com.xunlei.thunder" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Google\Chrome\NativeMessagingHosts\com.xunlei.thunder" /f /reg:32 >NUL 2>NUL
reg delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载" /f >NUL 2>NUL
reg delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载全部链接" /f >NUL 2>NUL
reg delete "HKCUHKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\&使用&迅雷离线下载" /f >NUL 2>NUL
reg delete "HKCUHKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\&使用&迅雷下载" /f >NUL 2>NUL
reg delete "HKCUHKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\&使用&迅雷下载全部链接" /f >NUL 2>NUL

reg delete "HKLM\SOFTWARE\Classes\APlayer3.Player" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\APlayer3.Player.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\APlayerUI.Player" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\APlayerUI.Player.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\AXmpLite" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{06A28264-EF0A-48E5-AD42-1327E5328955}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{99DC6162-65E4-476E-87CE-9E5944D323E2}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{AD13FB62-BF1B-4434-9BC3-20678B5287DE}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\ShlExt.DLL" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\UserAgent.DLL" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\XunleiBHO64.DLL" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{002AE4F2-96AB-4dfa-AE2E-605217F8A84C}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{002AE4F2-96AB-4dfa-AE2E-605217F8A84C}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{004B0726-A010-4abf-8556-FCDB7F1FCA1E}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{0119CCC1-8EAC-43E9-AA7D-87F64B44AA4D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{67486EAA-ED7F-4F84-82EB-26F23F57D690}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{889D2FEB-5411-4565-8998-1DD2C5261283}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{8F556DA3-987D-47b0-AA88-EB8D52FE1B9A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2C543E47-732B-4EDE-8AC9-C3D27C861FAA}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{559BAA6F-E3FE-4B0B-90D7-2C0BFA5145F1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{7BD58878-F0AE-406B-B5CE-871C4E01B237}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{CF1FC792-7F5C-4DB0-A00A-D209F5FFBD16}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\MiniXmpShlExt.ContextMenuExt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\MiniXmpShlExt.ContextMenuExt.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Thunder.MyComputerIcon" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Thunder.MyComputerIcon.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{01560F06-CEE2-46FF-8997-308A366175E9}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{1957CD06-E83F-477D-AD1A-5F6B8C30C561}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{26D657AE-A466-4F44-AB1D-5CFFFADBED97}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{32648605-550A-40FA-8F3B-90470FF9EE1F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{5E1356B8-3AD9-48AF-AA80-D76E5415E81B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{64A3A559-FFBB-49BA-A947-C6104804D644}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{97830570-35FE-4195-83DE-30E79B718713}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{A9757030-96F6-485E-A8AB-5B5137462472}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\UserAgent.Thunder59Agent" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\UserAgent.Thunder59Agent.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{1E935CBE-2951-48FE-93C8-4B7F1E5AA14E}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{22F1FF40-C53F-4360-A70E-F06540CB986B}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{23A860E9-0C41-4E01-9206-D3FC0E413645}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{485463B7-8FB2-4B3B-B29B-8B919B0EACCE}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{485463B7-8FB2-4B3B-B29B-8B919B0EACCE}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{6EE9CD3E-A386-4DAE-9737-A759DBF927AE}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A1E760B9-78EE-4570-909A-19ABF149F31E}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A63DEB30-9A77-492C-A380-3CA64A53C9EF}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A9332148-C691-4B9D-91FC-B9C461DBE9DD}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{C46DFF24-22C0-4C8F-87D0-5CADE3C2ADD6}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{DE05CF4A-7B0A-4775-B5E5-396244938679}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{F19169FA-7EB8-45EB-8800-0D1F7C88F553}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2C543E47-732B-4EDE-8AC9-C3D27C861FAA}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{559BAA6F-E3FE-4B0B-90D7-2C0BFA5145F1}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{7BD58878-F0AE-406B-B5CE-871C4E01B237}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{C46DFF24-22C0-4C8F-87D0-5CADE3C2ADD6}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{CF1FC792-7F5C-4DB0-A00A-D209F5FFBD16}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{F19169FA-7EB8-45EB-8800-0D1F7C88F553}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.3g2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.3gp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.3gp2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.3gpp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.aac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ac3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.acc" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.aiff" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.amr" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.amv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ape" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.asf" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ass" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.au" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.avi" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.bik" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.cda" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.csf" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.divx" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.dts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.dvd" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.evo" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.f4v" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.f5v" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.flac" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.flv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.hflv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.hlv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.hmkv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.hmp4" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.letv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m1a" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m1v" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m2a" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m2p" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m2ts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m2v" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m4a" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m4b" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m4p" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m4r" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.m4v" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mid" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.midi" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mk5" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mka" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mkv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mod" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mov" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mp2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mp2v" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mp3" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mp4" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mp5" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpa" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpc" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpeg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpeg1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpeg2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpeg4" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mpv2" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.mts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.oga" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ogg" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ogm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ogv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ogx" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.pmp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.psb" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.pva" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.qt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ra" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ram" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.rm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.rmvb" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.rpm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.rt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.scm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.smi" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.smil" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.srt" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ssa" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.sub" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.sup" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.swf" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.tp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.tpr" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.ts" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.tta" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.usf" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.vob" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.vp6" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.wav" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.wm" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.wma" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.wmp" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.wmv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.wv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\xmplite.xlmv" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Clients\Media\XMPLite" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{004B0726-A010-4ABF-8556-FCDB7F1FCA1E}" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{5DEB2780-5239-47C2-AEB7-B8BD9BEB3F80}" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{9FB5F2D4-203E-41D2-932F-6DE145F9756C}" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\XLGuard" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\XLServicePlatform" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\XLWFP" /f >NUL 2>NUL

reg delete "HKCU\CLSID\{004B0726-A010-4abf-8556-FCDB7F1FCA1E}" /f >NUL 2>NUL
reg delete "HKCU\CLSID\{DE05CF4A-7B0A-4775-B5E5-396244938679}" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Classes\.downlist" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.td" /f  >NUL 2>NUL
reg delete "HKCU\Software\Classes\.thunderskin" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.torrent" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.xlb" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\.xltd" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\ed2k" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\magnet" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\thunder" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\thunderx" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\xlb" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\Xunlei.Bittorrent.6" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\Xunlei.LSTFile.6" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\Xunlei.TDFile.6" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\Xunlei.ThunderSkin.6" /f >NUL 2>NUL
reg delete "HKCU\Software\Classes\Xunlei.XLB.6" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.torrent\OpenWithProgids" /f /v "Xunlei.Bittorrent.6" >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.xltd\OpenWithList" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.xltd\OpenWithProgids" /v "Xunlei.TDFile.6" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Mozilla\NativeMessagingHosts\com.xunlei.thunder" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\MozillaPlugins\@xunlei.com" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Thunder Network" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Ext\Stats\{002AE4F2-96AB-4dfa-AE2E-605217F8A84C}" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Ext\Stats\{485463B7-8FB2-4B3B-B29B-8B919B0EACCE}" /f >NUL 2>NUL

reg delete "HKCR\.td" /f >NUL 2>NUL
reg delete "HKCR\xlb" /f >NUL 2>NUL
reg delete "HKCR\.xlb" /f >NUL 2>NUL
reg delete "HKCR\.xltd" /f >NUL 2>NUL
reg delete "HKCR\ed2k" /f >NUL 2>NUL
reg delete "HKCR\magnet" /f >NUL 2>NUL
reg delete "HKCR\thunder" /f >NUL 2>NUL
reg delete "HKCR\thunderx" /f >NUL 2>NUL
reg delete "HKCR\.torrent" /f >NUL 2>NUL
reg delete "HKCR\.downlist" /f >NUL 2>NUL
reg delete "HKCR\.thunderskin" /f >NUL 2>NUL
reg delete "HKCR\ThunderSkin.6" /f >NUL 2>NUL
reg delete "HKCR\Xunlei.XLB.6" /f >NUL 2>NUL
reg delete "HKCR\Xunlei.TDFile.6" /f >NUL 2>NUL
reg delete "HKCR\Xunlei.LSTFile.6" /f >NUL 2>NUL
reg delete "HKCR\Xunlei.Bittorrent.6" /f >NUL 2>NUL
reg delete "HKCR\Xunlei.ThunderSkin.6" /f >NUL 2>NUL

reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "%~dp0Program\Thunder.exe" >NUL 2>NUL

CLS
ECHO.&ECHO 423down.com

DEL /F/Q "%~dp0BHO\ThunderAgent*.dll" >NUL 2>NUL
IF EXIST "%~dp0BHO\ThunderAgent.dll" ren "%~dp0BHO\ThunderAgent.dll" "ThunderAgent.dll.%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
IF EXIST "%~dp0BHO\ThunderAgent64.dll" ren "%~dp0BHO\ThunderAgent64.dll" "ThunderAgent64.dll.%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.tmp" >NUL 2>NUL
PUSHD .. & RD /S/Q "%~DP0" 2>NUL
