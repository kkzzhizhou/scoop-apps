@echo off
setlocal

for /f %%i in ('scoop which scoop') do (
	set VALID=%%~dpi..\supporting\validator\bin\validator.exe
	set SCHEMA=%%~dpi..\schema.json
)

if "x%~1" == "x" goto vldall

:vldone
if "x%~1" == "x" goto end
%VALID%  %SCHEMA% "%~nx1"
shift
goto :vldone

:vldall
%VALID%  %SCHEMA% * | grep -v "validates against the schema!"

:end