@echo off
setlocal EnableDelayedExpansion EnableExtensions

set root=C:\github\rasa

set repos=https://github.com/rasa/scoop
set repos=%repos% https://github.com/rasa/scoop-extras
set repos=%repos% https://github.com/scoopinstaller/versions
set repos=%repos% https://github.com/scoopinstaller/nightlies
set repos=%repos% https://github.com/kodybrown/scoop-nirsoft

for %%i in (%repos%) do (
    for %%j in (%%i) do set dir=%%~nj
    set repo=%root%\!dir!
    if not exist "!repo!" (
        git clone %%i "!repo!"
    )
)

for %%i in (%repos%) do (
    for %%j in (%%i) do set dir=%%~nj
    set repo=%root%\!dir!
    if exist "!repo!\bucket" (
        set repo=!repo!\bucket
    )

    call .\validate.cmd "!repo!\*.json"
    if %errorlevel% neq 0 goto :eof
)
