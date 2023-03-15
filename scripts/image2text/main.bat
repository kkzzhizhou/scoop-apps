@echo off
:WinNT
setlocal
@REM ensure the script will be executed with the Python it was installed for
set path=%~dp0;%~dp0..;%path%
@REM try the script named as the .bat file in current dir, then in Scripts subdir
set scriptname=%~dp0%~n0.py
if not exist "%scriptname%" set scriptname=%~dp0Scripts\%~n0.py
python "%scriptname%" %*