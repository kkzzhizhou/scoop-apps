@ECHO OFF&PUSHD %~DP0 &TITLE 绿化
@ echo.
ver|findstr "5\.[0-9]\.[0-9][0-9]*">nul && goto skip
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)
:skip
@ echo.
@ echo. 绿化前请先确保 Visual C++ 和 Universal C 运行库已安装齐全，
@ echo.
@ echo. 使用 'scoop install vcredist-aio' 或 'scoop install vcredist-mix' 安装运行库，
@ echo.
@ echo. 否则绿化过程中会报错，QQ 也可能会不能正常运行。
@ echo.
@ echo.
 pause

:: 安装前结束相关进程
taskkill /f /im TXP* >NUL 2>NUL
taskkill /f /im tad* >NUL 2>NUL
taskkill /f /im QQP* >NUL 2>NUL
taskkill /f /im QQC* >NUL 2>NUL
taskkill /f /im QQ.exe >NUL 2>NUL

:: 清理后台相关文件及注册残留
del /f /q "%TMP%\*.tvl" >NUL 2>NUL
del /f /q "%TMP%\*.tsd" >NUL 2>NUL
del /f /q "%TMP%\ts*.dat" >NUL 2>NUL
del /f /q "%TMP%\QQSa*.exe" >NUL 2>NUL
rd /s /q "%AppData%\Tencent\QQ"  2>NUL
rd /s /q "%AppData%\Tencent\Logs"2>NUL
rd /s /q "%AppData%\Tencent\Users"2>NUL
rd /s /q "%AppData%\Tencent\QTalk"2>NUL
rd /s /q "%AppData%\Tencent\QQLite"2>NUL
rd /s /q "%AppData%\Tencent\QQDoctor"2>NUL
rd /s /q "%AppData%\Tencent\DeskUpdate"2>NUL
rd /s /q "%AppData%\Tencent\QQMiniDL"2>NUL
rd /s /q "%AppData%\Tencent\Tencentdl"2>NUL
rd /s /q "%AppData%\Tencent\TenioDL"2>NUL
rd /s /q "%AppData%\Tencent\WebGamePlugin"2>NUL
rd /s /q "%AppData%\Tencent\File"2>NUL
rd /s /q "%AppData%\Tencent\Security001"2>NUL
rd /s /q "%AppData%\Tencent\AndroidAssist"2>NUL
rd /s /q "%AppData%\Tencent\AndroidServer"2>NUL
rd /s /q "%AppData%\Tencent\QQPhoneManager"2>NUL
rd /s /q "%AppData%\Tencent\QQPhoneAssistant"2>NUL
rd /s /q "%ProgramData%\Tencent\QQProtect"2>NUL
rd /s /q "%UserProfile%\Documents\Tencent"   2>NUL
rd /s /q "%UserProfile%\My Documents\Tencent"2>NUL
rd /s /q "%UserProFile%\AppData\LocalLow\QQMiniDL"2>NUL
rd /s /q "%UserProfile%\AppData\Local\Tencent\QQPet"2>NUL
rd /s /q "%UserProfile%\AppData\Local\Tencent\MiniBrowser"  2>NUL
rd /s /q "%UserProfile%\Local Settings\Tencent\QQPet"2>NUL
rd /s /q "%UserProfile%\Local Settings\QQKartLiveUpdate"2>NUL
rd /s /q "%UserProfile%\Documents\Tencent Files\QPlus"   2>NUL
rd /s /q "%UserProfile%\My Documents\Tencent Files\QPlus"2>NUL
rd /s /q "%AllUsersProfile%\Application Data\QQPet"2>NUL
rd /s /q "%AllUsersProfile%\Application Data\Tencent\QQProtect"2>NUL
rd /s /q "%CommonProgramFiles%\Tencent\QQProtect"2>NUL
rd /s /q "%CommonProgramFiles(x86)%\Tencent\QQProtect"2>NUL
reg delete HKLM\SYSTEM\CurrentControlSet\services\QQProtect /F>NUL 2>NUL

:: 注册协议: 关联网页会话、表情包关联、音乐收听等
if exist Bin\Timwp.dll regsvr32 /s Bin\Timwp.dll
if exist Bin\AppCom.dll regsvr32 /s Bin\AppCom.dll
if exist Bin\Common.dll regsvr32 /s Bin\Common.dll
if exist Bin\CPHelper.dll regsvr32 /s Bin\CPHelper.dll
if exist Bin\TXPFProxy.dll regsvr32 /s Bin\TXPFProxy.dll
if exist Bin\KernelUtil.dll regsvr32 /s Bin\KernelUtil.dll
if exist Bin\TXPlatform.exe Bin\TXPlatform.exe /RegServer
if exist Bin\QQExternal.exe Bin\QQExternal.exe /SetupRegister

:: 注册谷歌、火狐、Opera 快速登陆控件
regsvr32 /s Bin\TXSSO\Npchrome\npactivex.dll

:: 注册SSO核心库、IE及接口快速登陆控件
regsvr32 /s Bin\TXSSO\Bin\SSOCommon.dll
regsvr32 /s Bin\TXSSO\Bin\npSSOAxCtrlForPTLogin.dll

:: 注册中转站上传，群共享、微云上传控件
regsvr32 /s Plugin\Com.Tencent.NetDisk\Bin\QQDisk\Bin\TXFTNActiveX.dll

:: 注册点播控件，精简集成，免去后续安装
regsvr32 /s Bin\TXSSO\QzoneMusic\QzoneMusic.dll
if exist Bin\TXSSO\QzoneMusic\QzoneMusic.exe Bin\TXSSO\QzoneMusic\QzoneMusic.exe /RegServer

:: 传送QQ便签引导，不传送到后台位置则面板图标无法启动
xcopy /s/i/y Bin\TXSSO\QQApp "%AppData%\Tencent\QQ\QQApp" >NUL 2>NUL

:: 生成个人文件夹保存位置配置文件，让 Win7、Win8 或更高版的系统能正常保存自定义路径
if not exist "%Public%\Documents\Tencent\QQ" md "%Public%\Documents\Tencent\QQ"2>NUL
if not exist "%Public%\Documents\Tencent\QQ\UserDataInfo.ini" echo.>"%Public%\Documents\Tencent\QQ\UserDataInfo.ini"2>NUL

:: 设置安装路径，安装视频留言和影音播放等组件下载需要
if not exist "%WinDir%\SysWOW64" reg add HKLM\Software\Tencent\QQ2009 /v Install /d "%~dp0\" /f >NUL
if exist "%WinDir%\SysWOW64" reg add HKLM\Software\Wow6432Node\Tencent\QQ2009 /v Install /d "%~dp0\" /f >NUL

:: 设置安装版本号，企业类型网页会话需要，CRM组件需保留
if not exist "%WinDir%\SysWOW64" reg add HKLM\Software\Tencent\QQ2009 /v version /d "58.51.0.28008.0" /f >NUL
if exist "%WinDir%\SysWOW64" reg add HKLM\Software\Wow6432Node\Tencent\QQ2009 /v version /d "58.51.0.28008.0" /f >NUL

@REM :DesktopLnk
@REM ::提示安装完成了，可选创建桌面快捷方式。
@REM ECHO.&ECHO.绿化安装完成! 是否创建桌面快捷方式？
@REM ECHO.&ECHO.[是] 请按任意键，[否] 直接关掉本窗口!&PAUSE >NUL 2>NUL
@REM mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\腾讯QQ.lnk""):b.TargetPath=""%~dp0Bin\QQScLauncher.exe"":b.WorkingDirectory=""%~dp0Bin"":b.Save:close")
@REM ECHO.&ECHO.完成! &PAUSE >NUL 2>NUL

ECHO. >NUL&EXIT
