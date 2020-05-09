@echo off

set _1=%*

if not defined _1 set _1=*.json

for %%i in (%_1%) do (
    py %~dp0jsonfmt.py "%%~i"
)
