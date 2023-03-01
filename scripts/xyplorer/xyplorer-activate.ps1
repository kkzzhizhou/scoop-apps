Copy-Item "$(scoop prefix xyplorer-pro-crack)\XYplorer.Keygen.Activator.exe"  "$(scoop prefix xyplorer-pro-portable)" -ErrorAction SilentlyContinue -Force

sudo Start-Process "$(scoop prefix xyplorer-pro-portable)\XYplorer.Keygen.Activator.exe" -ArgumentList @("/activateinstall") -WorkingDirectory "$(scoop prefix xyplorer-pro-portable)" -WindowStyle Hidden
