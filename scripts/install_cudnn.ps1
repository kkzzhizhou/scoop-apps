if (!$env:CUDA_PATH) {
    Write-Error "Environment variable 'CUDA_PATH' not found."
    return
}
sudo Copy-Item -LiteralPath (Get-ChildItem -LiteralPath $dir).FullName -Destination $env:CUDA_PATH -Recurse -Force
