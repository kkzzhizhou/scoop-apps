@chcp 65001
@echo,
@echo,=====
@echo,SPDX-License-Identifier: (GPL-2.0+):
@echo,
@echo,!!! THIS IS NOT GUARANTEED TO WORK !!!
@echo,
@echo,Copyright (c) 2018-2022, SayCV
@echo,=====
@echo,

@REM @if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
@cd /d "%~dp0"
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



:: ---------------------------------------------------------------------------------------------------
:: ===================================================================================================

if "xy" == "xy" if exist "%~n0.sh" wsl -u wsl cd $PRE_NAMESPACE_PWD;./%~n0.sh

:: =========================
DELAY 3 2>nul || ping -n 3 127.0.0.1>nul
EXIT
