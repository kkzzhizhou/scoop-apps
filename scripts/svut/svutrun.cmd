:: This wrapper script is necessary to make the "svutRun" command on windows work

::@SET "PYTHON_EXE=%~dp0\..\python.exe"
call "python" "%~dp0\svutRun.py" %*
