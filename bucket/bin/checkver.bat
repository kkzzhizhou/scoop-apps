@echo off
setlocal

for /f %%i in ('scoop which scoop') do set CHECKVER=%%~dpicheckver.ps1
for /f %%i in ('scoop which pwsh') do set PWSH=%%i
if "%PWSH%x" == "x" for /f %%i in ('scoop which powershell') do set PWSH=%%i

for %%i in (%0) do set DIR=%%~dpi..

if "x%~1" == "x" goto updall

:updone
if "x%~1" == "x" goto end
%PWSH% -noprofile -ex unrestricted -f %CHECKVER% -dir %DIR% "%~n1"
shift
goto :updone

:updall
%PWSH% -noprofile -ex unrestricted -f %CHECKVER% -dir %DIR%

:end
