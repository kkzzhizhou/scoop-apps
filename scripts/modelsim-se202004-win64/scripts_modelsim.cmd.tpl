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
@set "EVAL_INST_PATH=%TOPDIR:\=/%"
@set "EVALROOT=%EVAL_INST_PATH%/Programs"

:: ---------------------------------------------------------------------------------------------------
:: ===================================================================================================
@set "PATH=%EVALROOT%/win64;%EVAL_INST_PATH%/gcc-4.5.0-mingw64vc12;%PATH%"

::@set "HOME=%EVAL_INST_PATH%/home"

@for /f  %%a in  ('hostname') do @set HOSTNAME=%%a
@set "MGLS_LICENSE_FILE=%EVAL_INST_PATH%/data/LICENSE.TXT"

:: =====
@set "TKL_CLASS=EDA/ModelSim"
@set "TKL_ROOTDIR=%EVAL_INST_PATH%"
@set "TKL_WORKDIR=%HOME%"
@set "TKL_RUNNER=%TKL_ROOTDIR%/scripts/@SCRIPT_NAME@.cmd"
@set "TKL_RUNNER_ICON=%TKL_ROOTDIR%/@SCRIPT_RUNNER_RELDIR@/@SCRIPT_RUNNER_ICON@"
@set "TKL_REGITEM=@SCRIPT_LNKNAME@"
@set "TKL_PROMPT=Open With %TKL_REGITEM%"
@if not exist "%userprofile%/Desktop/%TKL_CLASS%/%TKL_REGITEM%.lnk" @call :Establish

:: =====
@set skip=1
@for %%a in (%*) do @(
  @if not !position! lss !skip! @(
    @set args=!args! %%a
  ) else @(
    @set /a "position=!position!+1"
  )
)
@START @SCRIPT_RUNNER@.exe %SCRIPT_RUNNER_ARG% %*

:: =====
:script-done
:failure

@IF NOT %ERRORLEVEL% == 0  @PAUSE && @EXIT 1
@EXIT 0

:: =====
:: ---------------------------------------------------------------------------------------------------
:: =====

:Establish
    @if not exist "%userprofile%/Desktop/%TKL_CLASS%" @mkdir "%userprofile%\Desktop\%TKL_CLASS:/=\%"
    @mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\%TKL_CLASS:/=\%\%TKL_REGITEM%.lnk""):b.TargetPath=""%TKL_RUNNER%"":b.IconLocation=""%TKL_RUNNER_ICON%, 0"":b.WorkingDirectory=""%TKL_WORKDIR%"":b.Save:close")
    @EXIT /B 0
