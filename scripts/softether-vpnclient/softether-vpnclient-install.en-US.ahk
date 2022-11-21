#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 1
SetControlDelay -1

; Title for setup windows
winInstallTitle := "SoftEther VPN Setup Wizard"
agreeEULText := "I agree to the End User License Agreement"
specifyDirText := "Specify the Directory"
openAppText := "Start the SoftEther VPN Client Manager."
winInstallFinishedText := "The setup process of SoftEther VPN Client has completed successfully"

;MsgBox % "softether-vpn-client Setup"
WinWait, % winInstallTitle
WinActivate
Send {Enter}
WinActivate
Send {Enter}
WinActivate
Send {Enter}

;MsgBox % "softether-vpn-client License"
WinWait, % winInstallTitle, % agreeEULText
WinActivate
Gui, Add, Checkbox, vAgreeEUL, % agreeEULText
Gui, Submit, NoHide ;
If (AgreeEUL = 0) {
	WinActivate
	Send {Enter}
    Send {Tab}
    Send {Tab}
    Send {Space}
    Send {Enter}
}

;MsgBox % "softether-vpn-client Setup"
WinWait, % winInstallTitle
WinActivate
Send {Enter}
WinActivate
If (0 = 0) {
    Send {Tab}
	Send {Down}
    Send {Tab}
    ; WinWait, % winInstallTitle, % specifyDirText
    Send {Text}%A_ScriptDir%
    Send {Tab}
    Send {Tab}
    Send {Tab}
}
Send {Enter}

WinActivate
Send {Enter}

;MsgBox % "softether-vpn-client Setup Finish"
WinWait, % winInstallTitle, % winInstallFinishedText
WinActivate
Gui, Add, Checkbox, vAgreeOpenApp, % openAppText
Gui, Submit, NoHide ;
If (AgreeOpenApp = 0) {
	WinActivate
    Send {Tab}
    Send {Space}
	Send {Enter}
} 
Else {
	Send {Enter}
}

ExitApp