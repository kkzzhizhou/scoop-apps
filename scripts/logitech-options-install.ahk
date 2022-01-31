#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2
SetTitleMatchMode, fast

WinWait, LogiOptions Installer,, 300
while WinExist("LogiOptions Installer")
   {
    WinActivate
    Send {Enter}
	Sleep 2000
   }
exit
