@echo off
setlocal

for /f %%i in ('scoop which scoop') do (
    set CHECKVER=%%~dpicheckver.ps1
    set FORMAT=%%~dpiformatjson.ps1
)
for /f %%i in ('scoop which pwsh') do set PWSH=%%i
if "%PWSH%x" == "x" for /f %%i in ('scoop which powershell') do set PWSH=%%i

for %%i in (%0) do set DIR=%%~dpi..

git checkout master

if "x%~1" == "x" goto updall

:updone
if "x%~1" == "x" goto commit
%PWSH% -noprofile -ex unrestricted -f %CHECKVER% -dir %DIR% "%~n1" -u
shift
goto :updone

:updall
%PWSH% -noprofile -ex unrestricted -f %CHECKVER% -dir %DIR% -u

:commit
for /f %%i in ('git diff --name-only') do (
    git add %%i
    for /f %%v in ('jq .version %%i') do (
        git commit -m "%%~ni: Update to version %%v"
        git tag "%%~ni-%%v"
    )
)
::git push origin master
::git checkout -f master

:end
