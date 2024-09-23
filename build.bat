@echo off
setlocal

ECHO Starting vsix code signing...

PowerShell -File %KOKORO_BUILD_CONFIG_DIR%\sign_vsix.ps1

EXIT /b %ERRORLEVEL%