if (!$env:CUDA_PATH) {
    Write-Error "Environment variable 'CUDA_PATH' not found."
    return
}
$cudnnFiles = Get-ChildItem -LiteralPath $env:CUDA_PATH -File -Recurse | Where-Object {
    $_.Name -like 'cudnn64.*.dll' -or
    $_.Name -like 'cudnn.h' -or
    $_.Name -like 'cudnn.lib'
}
sudo Remove-Item -LiteralPath $cudnnFiles -Force
