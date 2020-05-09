@echo off
setlocal EnableDelayedExpansion EnableExtensions

set _1=%*

if not defined _1 set _1=*.json

set error=

del *.failed >nul 2>nul

for %%i in (%_1%) do (
    if exist "%%~i.failed" (
        del "%%~i.failed"
    )
    py -3 %~dp0\validate.py "%%~i"
)
exit /b 0
