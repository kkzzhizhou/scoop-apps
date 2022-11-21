#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 1
SetControlDelay -1

; Title for setup windows
winInstallTitle := "SoftEther VPN 安装向导"
agreeEULText := "我同意最终用户许可协议。"
specifyDirText := "Specify the Directory"
openAppText := "开启 SoftEther VPN Client 管理工具."
winInstallFinishedText := "SoftEther VPN Client 安装过程已成功完成。"

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