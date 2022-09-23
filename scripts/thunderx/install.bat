@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)

ver|findstr "5\.[0-9]\.[0-9][0-9]*" > NUL && (
ECHO.&ECHO 当前版本不支持WinXP &PAUSE>NUL&EXIT)

taskkill /f /im XMP.exe >NUL 2>NUL
taskkill /f /im XLLiveUD* >NUL 2>NUL
taskkill /f /im Thunder* /T >NUL 2>NUL
taskkill /f /im xlbrowsershell* >NUL 2>NUL
taskkill /f /im DownloadSDKServer* >NUL 2>NUL

::清除相关残留文件
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
rd/s/q "%PUBLIC%\Documents\Thunder Network"2>NUL
rd/s/q "%CommonProgramW6432%\Thunder Network"2>NUL
del/q "%ProgramData%\APlayerCodecs3.exe" >NUL 2>NUL
rd/s/q "%CommonProgramFiles(x86)%\Thunder Network"2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\XunLei"2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\XunleiBHO"2>NUL
del/q "%UserProfile%\AppData\APlayerCodecs3.exe" >NUL 2>NUL
rd/s/q "%UserProfile%\AppData\LocalLow\Thunder Network"2>NUL
del/q "%AppData%\Microsoft\Windows\Libraries\迅雷下载.library-ms" >NUL 2>NUL

::允许防火墙入站规则
netsh advfirewall firewall add rule name="Thunder" dir=in action=allow program="%~dp0Program\Thunder.exe" >NUL 2>NUL
netsh advfirewall firewall add rule name="DownloadSDKServer" dir=in action=allow program="%~dp0Program\resources\bin\SDK\DownloadSDKServer.exe" >NUL 2>NUL

::阻止后台P2P偷偷上传
rd/s/q "%PUBLIC%\Thunder Network"2>NUL
md "%PUBLIC%\Thunder Network\cid_store.dat" 2>NUL
md "%PUBLIC%\Thunder Network\tp_common_info.dat" 2>NUL
md "%PUBLIC%\Thunder Network\emule_upload_list.dat" 2>NUL

::迅雷所在路径检测键值
IF NOT EXIST "%ProgramW6432%" (
reg add "HKLM\SOFTWARE\Thunder Network\ThunderOem\thunder_backwnd" /f /v "dir" /d "%~dp0\" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Thunder Network\ThunderOem\thunder_backwnd" /f /v "instdir" /d "%~dp0\" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Thunder Network\ThunderOem\thunder_backwnd" /f /v "Path" /d "%~dp0Program\Thunder.exe" >NUL 2>NUL
) ELSE (
reg add "HKLM\SOFTWARE\Wow6432Node\Thunder Network\ThunderOem\thunder_backwnd" /f /v "dir" /d "%~dp0\" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Wow6432Node\Thunder Network\ThunderOem\thunder_backwnd" /f /v "instdir" /d "%~dp0\" >NUL 2>NUL
reg add "HKLM\SOFTWARE\Wow6432Node\Thunder Network\ThunderOem\thunder_backwnd" /f /v "Path" /d "%~dp0Program\Thunder.exe" >NUL 2>NUL
)

::注册IE浏览器或基于IE内核程序关联组件
regsvr32 /s "%~dp0BHO\ThunderAgent.dll"
regsvr32 /s "%~dp0BHO\ThunderAgent64.dll"
regsvr32 /s "%~dp0Program\np_tdieplat.dll"

::Chrme, firefox扩展检测识别路径键值项
reg delete "HKLM\SOFTWARE\Wow6432Node\Google\Chrome\NativeMessagingHosts\com.xunlei.thunder" /f >NUL 2>NUL
reg add "HKLM\SOFTWARE\Google\Chrome\NativeMessagingHosts\com.xunlei.thunder" /f /ve /d "%~dp0Program\com.xunlei.thunder.json" >NUL 2>NUL
IF NOT EXIST "%ProgramW6432%" (
reg add "HKLM\SOFTWARE\MozillaPlugins\@xunlei.com/npxunlei;version=1.0.0.2" /f /v "path" /d "%~dp0Program\npxunlei.dll" >NUL 2>NUL
) ELSE (
reg add "HKLM\SOFTWARE\Wow6432Node\MozillaPlugins\@xunlei.com/npxunlei;version=1.0.0.2" /f /v "path" /d "%~dp0Program\npxunlei.dll" >NUL 2>NUL
)

::添加网页右键菜单下载项
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\使用迅雷下载" /f /ve /d "%~dp0BHO\geturl.htm"  >NUL 2>NUL
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\使用迅雷下载" /f /v "Contexts" /t REG_DWORD /d "0x00000022" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\使用迅雷下载全部链接" /f /ve /d "%~dp0BHO\getAllurl.htm" >NUL 2>NUL
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\MenuExt\使用迅雷下载全部链接" /f /v "Contexts" /t REG_DWORD /d "0x000000f3" >NUL 2>NUL

::关联相关的文件类型协议
reg add "HKCR\ed2k" /f /v "URL Protocol" /d "" >NUL 2>NUL
reg add "HKCR\ed2k\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\" -StartType:ed2k" >NUL 2>NUL
reg add "HKCR\magnet" /f /v "URL Protocol" /d "" >NUL 2>NUL
reg add "HKCR\magnet\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\" -StartType:magnet" >NUL 2>NUL
reg add "HKCR\thunder" /f /v "URL Protocol" /d "" >NUL 2>NUL
reg add "HKCR\thunder\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\" -StartType:thunder" >NUL 2>NUL
reg add "HKCR\thunderx" /f /v "URL Protocol" /d "" >NUL 2>NUL
reg add "HKCR\thunderx\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\" -StartType:thunderx" >NUL 2>NUL

reg add "HKCR\.torrent" /f /ve /d "Xunlei.Bittorrent.6" >NUL 2>NUL
reg add "HKCR\Xunlei.Bittorrent.6" /f /ve /d "BT种子文件" >NUL 2>NUL
reg add "HKCR\Xunlei.Bittorrent.6\DefaultIcon" /f /ve /d "%~dp0Program\TorrentFile.ico" >NUL 2>NUL
reg add "HKCR\Xunlei.Bittorrent.6\Shell\Open" /f /ve /d "使用迅雷下载该BT文件" >NUL 2>NUL
reg add "HKCR\Xunlei.Bittorrent.6\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\"" >NUL 2>NUL

reg add "HKCR\.downlist" /f /ve /d "Xunlei.LSTFile.6" >NUL 2>NUL
reg add "HKCR\Xunlei.LSTFile.6" /f /ve /d "迅雷专有下载文件" >NUL 2>NUL
reg add "HKCR\Xunlei.LSTFile.6\DefaultIcon" /f /ve /d "%~dp0Program\XLDownloadList.ico" >NUL 2>NUL
reg add "HKCR\Xunlei.LSTFile.6\Shell\Open" /f /ve /d "使用迅雷下载该任务列表文件" >NUL 2>NUL
reg add "HKCR\Xunlei.LSTFile.6\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\"" >NUL 2>NUL

reg add "HKCR\.td" /f /ve /d "Xunlei.TDFile.6" >NUL 2>NUL
reg add "HKCR\.xltd" /f /ve /d "Xunlei.TDFile.6" >NUL 2>NUL
reg add "HKCR\Xunlei.TDFile.6" /f /ve /d "迅雷临时数据文件" >NUL 2>NUL
reg add "HKCR\Xunlei.TDFile.6\DefaultIcon" /f /ve /d "%~dp0Program\XLTempFile.ico" >NUL 2>NUL
reg add "HKCR\Xunlei.TDFile.6\Shell\Open" /f /ve /d "使用迅雷下载未完成文件" >NUL 2>NUL
reg add "HKCR\Xunlei.TDFile.6\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\"" >NUL 2>NUL

reg add "HKCR\.xlb" /f /ve /d "Xunlei.XLB.6" >NUL 2>NUL
reg add "HKCR\xlb" /f /v "URL Protocol" /d "" >NUL 2>NUL
reg add "HKCR\Xunlei.XLB.6" /f /ve /d "迅雷下载合集文件" >NUL 2>NUL
reg add "HKCR\Xunlei.XLB.6\DefaultIcon" /f /ve /d "%~dp0Program\DownloadCollection.ico" >NUL 2>NUL
reg add "HKCR\Xunlei.XLB.6\Shell\Open" /f /ve /d "使用迅雷查看该下载合集文件" >NUL 2>NUL
reg add "HKCR\Xunlei.XLB.6\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\"" >NUL 2>NUL
reg add "HKCR\xlb\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\" -StartType:xlb" >NUL 2>NUL

reg add "HKCR\.thunderskin" /f /ve /d "Xunlei.ThunderSkin.6" >NUL 2>NUL
reg add "HKCR\Xunlei.ThunderSkin.6" /f /ve /d "迅雷X皮肤文件" >NUL 2>NUL
reg add "HKCR\Xunlei.ThunderSkin.6\DefaultIcon" /f /ve /d "%~dp0Program\thunderskin.ico" >NUL 2>NUL
reg add "HKCR\Xunlei.ThunderSkin.6\Shell\Open" /f /ve /d "为迅雷X应用该皮肤" >NUL 2>NUL
reg add "HKCR\Xunlei.ThunderSkin.6\Shell\Open\command" /f /ve /d "\"%~dp0Program\Thunder.exe\" \"%%1\"" >NUL 2>NUL

ASSOC .=. >NUL 2>NUL

ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT
