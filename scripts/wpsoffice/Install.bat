@ECHO OFF&PUSHD %~DP0 &TITLE WPSOffice绿化程序
color 2F
SetLocal EnableDelayedExpansion
ECHO 停止相关进程
taskkill /f /im et*>NUL 2>NUL
taskkill /f /im wpp*>NUL 2>NUL
taskkill /f /im wps*>NUL 2>NUL
taskkill /f /im wpscloudsvr*>NUL 2>NUL
ksomisc.exe -setlng $CUR_LANG_STR$
ksomisc.exe -setservers
ksomisc.exe -register
ksomisc.exe -regmtfont
ksomisc.exe -Assoword
ksomisc.exe -Assoexcel
ksomisc.exe -Assopowerpnt
ksomisc.exe -Assopdf
ksomisc.exe -compatiblemso
ksomisc.exe -saveas_mso
ksomisc.exe -updatesaveto
ksomisc.exe -distsrc 000
ksomisc.exe -sendinstallinfo
ksomisc.exe -sendinstalldyn
ksomisc.exe -updatelink
ksomisc.exe -rebuildicon
rd/s/q "%AppData%\Kingsoft\office6"2>NUL
rd/s/q "%AppData%\Kingsoft\wps"2>NUL
del/f "%AppData%\Kingsoft\wps"2>NUL
rd/s/q "%AppData%\Kingsoft\kaccountsdk"2>NUL
rd/s/q "%AppData%\Kingsoft\kdynsdk"2>NUL
rd/s/q "%LocalAppData%\Kingsoft\WPS Cloud Files"2>nul
reg delete HKCU\Software\Kingsoft\Office /F>NUL 2>NUL
sc delete wpscloudsvr >NUL 2>NUL
reg add HKCR\.doc\WPS.Doc.6\ShellNew /v FileName /d "%cd%\mui\zh_CN\templates\newfile.wps" /F>NUL 2>NUL
reg add HKCR\.docx\WPS.Docx.6\ShellNew /v "FileName" /d "%cd%\mui\zh_CN\templates\newfile.wps" /F>NUL 2>NUL
reg add HKCR\.ppt\WPP.PPT.6\ShellNew /v "FileName" /d "%cd%\mui\zh_CN\templates\newfile.dps" /F>NUL 2>NUL
reg add HKCR\.pptx\WPP.PPTX.6\ShellNew /v "FileName" /d "%cd%\mui\zh_CN\templates\newfile.pptx" /F>NUL 2>NUL
reg add HKCR\.xls\ET.Xls.6\ShellNew /v "FileName" /d "%cd%\mui\zh_CN\templates\newfile.et" /F>NUL 2>NUL
reg add HKCR\.xlsx\ET.Xlsx.6\ShellNew /v "FileName" /d "%cd%\mui\zh_CN\templates\newfile.xlsx" /F>NUL 2>NUL
reg add HKCR\.xlsm\ET.Xlsm.6\ShellNew /v "FileName" /d "%cd%\mui\zh_CN\templates\newfile.xlsx" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\plugins\officespace /v "roaminghomepageguidedtag" /d "10.8.2.6613" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\et /v "uifile" /d "res/etongmani.kui" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\wps /v "uifile" /d "res/wpsongmani.kui" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\wpp /v "uifile" /d "res/wppongmani.kui" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\common /v "InstallRoot" /d "%~dp0" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\Common\wpshomeoptions /v "StartWithType" /t "REG_DWORD" /d "0" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\plugins\homepage /v "HasShowTip" /t "REG_SZ" /d "true" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\plugins\homepage /v "PresetChannel" /t "REG_SZ" /d "drive" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\plugins\officespace\flogin /v "userPaneShowed" /t "REG_SZ" /d "1" /F>NUL 2>NUL
reg add HKCU\Software\Kingsoft\Office\6.0\Common\updateinfo /v "UpdateRecommend" /t "REG_SZ" /d "false" /F>NUL 2>NUL
md  "%AppData%\Kingsoft\office6"2>NUL
echo.OfficeSpace>"%AppData%\Kingsoft\office6\OfficeSpace"2>NUL
echo.update>"%AppData%\Kingsoft\office6\update"2>NUL
echo.log> "%AppData%\Kingsoft\office6\log"2>NUL
echo.fonts> "%AppData%\Kingsoft\office6\fonts"2>NUL
echo.wps> "%AppData%\Kingsoft\wps"2>NUL
Attrib +r  "%AppData%\Kingsoft\office6\OfficeSpace" >NUL 2>NUL
Attrib +r  "%AppData%\Kingsoft\office6\update" >NUL 2>NUL
Attrib +r  "%AppData%\Kingsoft\office6\log" >NUL 2>NUL
Attrib +r  "%AppData%\Kingsoft\office6\fonts" >NUL 2>NUL
Attrib +r  "%AppData%\Kingsoft\wps" >NUL 2>NUL
md %AppData%\Kingsoft\office6\customui 2>NUL
cd /d %AppData%\Kingsoft\office6\customui 2>NUL
echo [common]>>ui.ini 2>NUL
echo qatUsed=true>>ui.ini 2>NUL
md "%LocalAppData%\Kingsoft\WPS Cloud Files\userdata\qing" 2>NUL
cd /d %LocalAppData%\Kingsoft\WPS Cloud Files\userdata\qing 2>NUL
echo [General]>>config.ini 2>NUL
echo autologin=1 >>config.ini 2>NUL
