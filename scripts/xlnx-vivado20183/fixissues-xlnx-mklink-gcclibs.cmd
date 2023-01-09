@chcp 65001
@echo,
@echo,=====
@echo,SPDX-License-Identifier: (GPL-2.0+):
@echo,
@echo,!!! THIS IS NOT GUARANTEED TO WORK !!!
@echo,
@echo,Copyright (c) 2018-2021, SayCV
@echo,=====
@echo,

@REM @if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
@cd /d "%~dp0/../"
@set "TOPDIR=%cd%"
@title "%~n0"

@REM Enable extensions, the `verify` call is a trick from the setlocal help
@VERIFY other 2>nul
@SETLOCAL EnableDelayedExpansion
@IF %ERRORLEVEL% == 1 @(
    @ECHO Unable to enable extensions
    @GOTO failure
)

:: =====
@set "VIVADO_TOPDIR=%TOPDIR:\=/%"
@set "VIVADO_TOPDIR=F:/Xilinx"
@set "VIVADO_VER=2018.3"
@set "VIVADO_HLSROOT=%VIVADO_TOPDIR%/Vivado/%VIVADO_VER%"
@set "VIVADO_SDKROOT=%VIVADO_TOPDIR%/SDK/%VIVADO_VER%"

@set "sdk=%VIVADO_SDKROOT%/bin/xsdk.bat"
@set "vivado=%VIVADO_HLSROOT%/bin/vivado.bat"

:: ---------------------------------------------------------------------------------------------------
:: ===================================================================================================
@set "PATH=%VIVADO_SDKROOT%/bin;%PATH%"
@set "PATH=%VIVADO_HLSROOT%/bin;%PATH%"

@set "HOME=%VIVADO_TOPDIR%/home"

@set "srcdir=%VIVADO_SDKROOT%/gnu/aarch32/nt/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/libc"
@GOTO :SKIP_FOUND_0KB_FILES
for /f "delims=" %%a in ('dir /a-d/b/s %srcdir:/=\%\lib') do (
    if "%%~za" equ "0" (
        echo;"%%a"
        del /a /f /q "%%a"
    )
)
for /f "delims=" %%a in ('dir /a-d/b/s %srcdir:/=\%\usr\lib') do (
    if "%%~za" equ "0" (
        echo;"%%a"
        del /a /f /q "%%a"
    )
)
:SKIP_FOUND_0KB_FILES

@set NL=^


@SET lkfiles=
@SET lkfiles=!lkfiles!!NL!ld-linux-armhf.so.3
@SET lkfiles=!lkfiles!!NL!libanl.so.1
@SET lkfiles=!lkfiles!!NL!libBrokenLocale.so.1
@SET lkfiles=!lkfiles!!NL!libc.so.6
@SET lkfiles=!lkfiles!!NL!libcidn.so.1
@SET lkfiles=!lkfiles!!NL!libcrypt.so.1
@SET lkfiles=!lkfiles!!NL!libdl.so.2
@SET lkfiles=!lkfiles!!NL!libm.so.6
@SET lkfiles=!lkfiles!!NL!libnsl.so.1
@SET lkfiles=!lkfiles!!NL!libnss_db.so.2
@SET lkfiles=!lkfiles!!NL!libnss_dns.so.2
@SET lkfiles=!lkfiles!!NL!libnss_files.so.2
@SET lkfiles=!lkfiles!!NL!libnss_hesiod.so.2
@SET lkfiles=!lkfiles!!NL!libpthread.so.0
@SET lkfiles=!lkfiles!!NL!libresolv.so.2
@SET lkfiles=!lkfiles!!NL!librt.so.1
@SET lkfiles=!lkfiles!!NL!libthread_db.so.1
@SET lkfiles=!lkfiles!!NL!libutil.so.1

::@echo !lkfiles!
@echo off
PUSHD %CD%&CD /d %srcdir:/=\%\lib
if not exist ld-linux-armhf.so.3 if exist ld-2.26.so mklink ld-linux-armhf.so.3 ld-2.26.so

@CALL :FX_MKLINK_GCC_LIBS %srcdir:/=\%\lib
POPD

:: =========================
DELAY 3 2>nul || ping -n 3 127.0.0.1>nul
EXIT 0

:FX_MKLINK_GCC_LIBS
    set "cmd=rustup show | grep %~1"

    for /f "delims=" %%a in ("!lkfiles!") do (
        set "line=%%a"
        echo processing : !line!
        FOR /F "tokens=1,2* delims=." %%A IN ("!line!") DO (
            set "varseg1=%%A"
        )
        if not exist !line! if exist !varseg1!-2.26.so mklink !line! !varseg1!-2.26.so
        if not exist !line! if exist !varseg1!-1.0.so mklink !line! !varseg1!-1.0.so

        if not exist %srcdir:/=\%\usr\lib\!varseg1!.so if exist !varseg1!-2.26.so mklink %srcdir:/=\%\usr\lib\!varseg1!.so %srcdir:/=\%\lib\!varseg1!-2.26.so
        if not exist %srcdir:/=\%\usr\lib\!varseg1!.so if exist !varseg1!-1.0.so  mklink %srcdir:/=\%\usr\lib\!varseg1!.so %srcdir:/=\%\lib\!varseg1!-1.0.so
    )
    EXIT /B 0
