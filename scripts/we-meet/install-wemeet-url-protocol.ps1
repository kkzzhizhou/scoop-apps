Write-Host "`n正在注册腾讯会议协议..."

# 创建主键
New-Item -Path "HKCU:\SOFTWARE\Classes\wemeet" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\wemeet" -Name "(default)" -Value "腾讯会议" -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\wemeet" -Name "URL Protocol" -Value "" -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\wemeet" -Name "UseOriginalUrlEncoding" -Value 1 -Type DWord -Force

# 创建 DefaultIcon
New-Item -Path "HKCU:\SOFTWARE\Classes\wemeet\DefaultIcon" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\wemeet\DefaultIcon" -Name "(default)" -Value "`"$WeMeetPath\WeMeet.exe`",1" -Force

# 创建 shell\open\command
New-Item -Path "HKCU:\SOFTWARE\Classes\wemeet\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\wemeet\shell\open\command" -Name "(default)" -Value "`"$WeMeetPath\WeMeet.exe`" `"%1`"" -Force

Write-Host "腾讯会议协议注册完成！" -ForegroundColor Green
