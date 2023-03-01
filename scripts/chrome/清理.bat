@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)
taskkill /f /im chrome* /t >NUL 2>NUL
taskkill /f /im TabPlus.exe >NUL 2>NUL
taskkill /f /im MyChrome.exe >NUL 2>NUL

rd/s/q "%ProgramData%\Google\Chrome"2>NUL
rd/s/q "%LocalAppData%\Google\Chrome"2>NUL
del/q "%Public%\Desktop\Chrome.lnk" >NUL 2>NUL
del/q "%UserProfile%\Desktop\Chrome.lnk" >NUL 2>NUL
rd/s/q "%AppData%\Microsoft\Windows\Start Menu\Programs\Google Chrome"2>NUL
rd/s/q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Google Chrome"2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Chrome" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Chrome" /f /reg:32 >NUL 2>NUL

reg delete "HKCU\SOFTWARE\Google\Update" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Google\Chrome" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Google\Update" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Google\Chrome" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Google\Update" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Google\Chrome" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\MediaPlayer\ShimInclusionList\chrome.exe" /f >NUL 2>NUL
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Chrome.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{4EB61BAC-A3B6-4760-9581-655041EF4D69}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{708860E0-F641-4611-8895-7D867DD3675B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\{9465B4B4-5216-4042-9A2C-754D3BCDC410}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\AppID\GoogleUpdate.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\ChromeHTML" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{708860E0-F641-4611-8895-7D867DD3675B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9AAA1336-C131-4B16-9A86-7BAF3B3B76F8}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9D6AA569-9F30-41AD-885A-346685C74928}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A2C6CB58-C076-425C-ACB7-6D19D64428CD}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E9957D25-7EB7-42C8-AD32-06AF7776A788}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CoCreateAsync" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CoCreateAsync.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CoreClass" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CoreClass.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CoreMachineClass" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CoreMachineClass.1" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CredentialDialogMachine" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.CredentialDialogMachine.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.OnDemandCOMClassMachine" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.OnDemandCOMClassMachine.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.OnDemandCOMClassMachineFallback" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.OnDemandCOMClassMachineFallback.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.OnDemandCOMClassSvc" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.OnDemandCOMClassSvc.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.PolicyStatus" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.PolicyStatus.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.ProcessLauncher" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.ProcessLauncher.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3COMClassService" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3COMClassService.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3WebMachine" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3WebMachine.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3WebMachineFallback" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3WebMachineFallback.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3WebSvc" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\GoogleUpdate.Update3WebSvc.1.0" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Installer\Features\A01655856B165233AA6AED6D9BC0FED8" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Installer\Products\A01655856B165233AA6AED6D9BC0FED8" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Installer\UpgradeCodes\96FDFD1C54952F233AE5EE499CC9C74F" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{084D78A8-B084-4E14-A629-A2C419B0E3D9}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{0CD01D1E-4A1C-489D-93B9-9B6672877C57}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{128C2DA6-2BC0-44C0-B3F6-4EC22E647964}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{18D0F672-18B4-48E6-AD36-6E6BF01DBBC4}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{19692F10-ADD2-4EFF-BE54-E61C62E40D13}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{1C642CED-CA3B-4013-A9DF-CA6CE5FF6503}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{247954F9-9EDC-4E68-8CC3-150C2B89EADF}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2D363682-561D-4C3A-81C6-F2F82107562A}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2E629606-312A-482F-9B12-2C4ABF6F0B6D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{31AC3F11-E5EA-4A85-8A3D-8E095A39C27B}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{3D05F64F-71E3-48A5-BF6B-83315BC8AE1F}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{463ABECF-410D-407F-8AF5-0DF35A005CC8}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{494B20CF-282E-4BDD-9F5D-B70CB09D351E}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{49D7563B-2DDB-4831-88C8-768A53833837}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4DE778FE-F195-4EE3-9DAB-FE446C239221}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4E223325-C16B-4EEB-AEDC-19AA99A237FA}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{5B25A8DC-1780-4178-A629-6BE8B8DEFAA2}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{6DB17455-4E85-46E7-9D23-E555E4B005AF}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{76F7B787-A67C-4C73-82C7-31F5E3AABC5C}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{8476CE12-AE1F-4198-805C-BA0F9B783F57}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{909489C2-85A6-4322-AA56-D25278649D67}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{B3A47570-0A85-4AEA-8270-529D47899603}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{BCDCB538-01C0-46D1-A6A7-52F4D021C272}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{D106AB5F-A70E-400E-A21B-96208C1D8DBB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DAB1D343-1B2A-47F9-B445-93DC50704BFE}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DCAB8386-4F03-4DBD-A366-D90BC9F68DE6}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DD42475D-6D46-496A-924E-BD5630B4CBBA}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{F63F6F8B-ACD5-413C-A44B-0409136D26CB}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{FE908CDD-22BB-472A-9870-1A0390E42F36}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{463ABECF-410D-407F-8AF5-0DF35A005CC8}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{25461599-633D-42B1-84FB-7CD68D026E53}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{4EB61BAC-A3B6-4760-9581-655041EF4D69}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{521FDB42-7130-4806-822A-FC5163FAD983}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{534F5323-3569-4F42-919D-1E1CF93E5BF6}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{598FE0E5-E02D-465D-9A9D-37974A28FD42}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{6F8BD55B-E83D-4A47-85BE-81FFA8057A69}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{7DE94008-8AFD-4C70-9728-C6FBFFF6A73E}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{8A1D4361-2C08-4700-A351-3EAA9CBFF5E4}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9465B4B4-5216-4042-9A2C-754D3BCDC410}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9AAA1336-C131-4B16-9A86-7BAF3B3B76F8}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9B2340A0-4068-43D6-B404-32E27217859D}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{9D6AA569-9F30-41AD-885A-346685C74928}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{ABC01078-F197-4B0B-ADBC-CFE684B39C82}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{B3D28DBD-0DFA-40E4-8071-520767BADC7E}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E225E692-4B47-4777-9BED-4FD7FE257F0E}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E9957D25-7EB7-42C8-AD32-06AF7776A788}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{084D78A8-B084-4E14-A629-A2C419B0E3D9}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{0CD01D1E-4A1C-489D-93B9-9B6672877C57}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{128C2DA6-2BC0-44C0-B3F6-4EC22E647964}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{18D0F672-18B4-48E6-AD36-6E6BF01DBBC4}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{19692F10-ADD2-4EFF-BE54-E61C62E40D13}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{1C642CED-CA3B-4013-A9DF-CA6CE5FF6503}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{247954F9-9EDC-4E68-8CC3-150C2B89EADF}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2D363682-561D-4C3A-81C6-F2F82107562A}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{2E629606-312A-482F-9B12-2C4ABF6F0B6D}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{31AC3F11-E5EA-4A85-8A3D-8E095A39C27B}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{3D05F64F-71E3-48A5-BF6B-83315BC8AE1F}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{494B20CF-282E-4BDD-9F5D-B70CB09D351E}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{49D7563B-2DDB-4831-88C8-768A53833837}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4DE778FE-F195-4EE3-9DAB-FE446C239221}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{4E223325-C16B-4EEB-AEDC-19AA99A237FA}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{5B25A8DC-1780-4178-A629-6BE8B8DEFAA2}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{6DB17455-4E85-46E7-9D23-E555E4B005AF}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{76F7B787-A67C-4C73-82C7-31F5E3AABC5C}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{8476CE12-AE1F-4198-805C-BA0F9B783F57}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{909489C2-85A6-4322-AA56-D25278649D67}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{B3A47570-0A85-4AEA-8270-529D47899603}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{BCDCB538-01C0-46D1-A6A7-52F4D021C272}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{D106AB5F-A70E-400E-A21B-96208C1D8DBB}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DAB1D343-1B2A-47F9-B445-93DC50704BFE}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DCAB8386-4F03-4DBD-A366-D90BC9F68DE6}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{DD42475D-6D46-496A-924E-BD5630B4CBBA}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{F63F6F8B-ACD5-413C-A44B-0409136D26CB}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Classes\Interface\{FE908CDD-22BB-472A-9870-1A0390E42F36}" /f /reg:32 >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Clients\StartMenuInternet\Google Chrome" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{8A69D345-D564-463c-AFF1-A69D9E530F96}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\MediaPlayer\ShimInclusionList\chrome.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5855610A-61B6-3325-AAA6-DED6B90CEF8D}" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GoogleUpdate.exe" /f >NUL 2>NUL
reg delete "HKLM\SOFTWARE\RegisteredApplications" /f /v "Google Chrome" >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application\Chrome" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\gupdate" /f >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\gupdatem" /f >NUL 2>NUL

CLS
ECHO.&ECHO 423Down.com
