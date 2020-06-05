#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 1
SetControlDelay -1
CoordMode, Mouse, Window

winTitle = Logitech Options Uninstaller

WinWait, %winTitle%, Logitech Options will be removed, 90
if (Errorlevel)
{
    ExitApp
}

WinActivate %winTitle%
ControlClick, &Uninstall, %winTitle%

WinWait, %winTitle%, Uninstall complete, 300
if (Errorlevel)
{
    ExitApp
}

WinActivate %winTitle%
ControlClick, &Close, %winTitle%
