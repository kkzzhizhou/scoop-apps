#SingleInstance, force, NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, RegEx

WinWait, Microsoft Windows, Restart Now, 30
hwnd := WinExist()
Sleep 200
ControlClick, Button2, ahk_id %hwnd% , , , , NA
