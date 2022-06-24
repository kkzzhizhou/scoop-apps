@ECHO OFF&PUSHD %~DP0 &TITLE WPSOffice卸载程序
color 2F
SetLocal EnableDelayedExpansion
echo 　　　正在卸载中..请稍等..
taskkill /f /im et*>NUL 2>NUL
taskkill /f /im wpp*>NUL 2>NUL
taskkill /f /im wps*>NUL 2>NUL
taskkill /f /im wpscloudsvr*>NUL 2>NUL
ksomisc.exe -rename 2052 uninstall
ksomisc.exe -externaltask delete
ksomisc.exe -uncompatiblemso
ksomisc.exe -unassoword
ksomisc.exe -unassopowerpnt
ksomisc.exe -unassoexcel
ksomisc.exe -unassopdf
ksomisc.exe -unregister
ksomisc.exe -unregmtfont
ksomisc.exe -unregksee -forceperusermode
ksomisc.exe -unassoofficexml
ksomisc.exe -rebuildicon
ksomisc.exe -unreg_wps
ksomisc.exe -unreg_wpp
ksomisc.exe -unreg_et
ksomisc.exe -unregksee
ksomisc.exe -unreg_kso
ksomisc.exe -unreg_kde
ksomisc.exe -unregoledefhndlr
ksomisc.exe -unregmtfont
sc delete wpscloudsvr >NUL 2>NUL
reg delete "HKCR\.doc\WPS.Doc.6" /F>NUL 2>NUL
reg delete "HKCR\.docx\WPS.Docx.6" /F>NUL 2>NUL
reg delete "HKCR\.ppt\WPP.PPT.6" /F>NUL 2>NUL
reg delete "HKCR\.pptx\WPP.PPTX.6" /F>NUL 2>NUL
reg delete "HKCR\.xls\ET.Xls.6" /F>NUL 2>NUL
reg delete "HKCR\.xlsx\ET.Xlsx.6" /F>NUL 2>NUL
reg delete "HKCR\.xlsm\ET.Xlsm.6" /F>NUL 2>NUL
reg delete "HKCU\Software\Kingsoft\Office" /F>NUL 2>NUL
reg delete "HKCU\Software\Kingsoft\wpscloud" /F>NUL 2>NUL
rd/s/q "%AppData%\Kingsoft\office6"2>NUL
rd/s/q "%AppData%\Kingsoft\wps"2>NUL
del/f "%AppData%\Kingsoft\wps"2>NUL
rd/s/q "%AppData%\Kingsoft\kaccountsdk"2>NUL
rd/s/q "%AppData%\Kingsoft\kdynsdk"2>NUL
rd/s/q "%LocalAppData%\Kingsoft\WPS Cloud Files"2>nul
del/f/q "%userprofile%\Desktop\WPS表格.lnk" >nul 2>nul
del/f/q "%userprofile%\Desktop\WPS演示.lnk" >nul 2>nul
del/f/q "%userprofile%\Desktop\WPS文字.lnk" >nul 2>nul
del/f/q "%userprofile%\桌面\WPS表格.lnk" >nul 2>nul
del/f/q "%userprofile%\桌面\WPS演示.lnk" >nul 2>nul
del/f/q "%userprofile%\桌面\WPS文字.lnk" >nul 2>nul
del/f/q "%public%\Desktop\WPS表格.lnk" >nul 2>nul
del/f/q "%public%\Desktop\WPS演示.lnk" >nul 2>nul
del/f/q "%public%\Desktop\WPS文字.lnk" >nul 2>nul
del/f/q "%public%\桌面\WPS表格.lnk" >nul 2>nul
del/f/q "%public%\桌面\WPS演示.lnk" >nul 2>nul
del/f/q "%public%\桌面\WPS文字.lnk" >nul 2>nul
