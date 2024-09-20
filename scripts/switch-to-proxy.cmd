@echo off
IF DEFINED http_proxy (
   @echo Set local credential.github.com.httpProxy to %http_proxy%
@REM   git config --local http.proxy %http_proxy%
   git config --local credential.github.com.httpProxy %http_proxy%
) ELSE (
  @echo Unset local credential.github.com.httpProxy
  git config --local --unset http.proxy
  git config --local --unset credential.github.com.httpProxy
)
