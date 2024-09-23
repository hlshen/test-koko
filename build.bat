@echo off
setlocal

ECHO Starting vsix code signing...

PowerShell -File %KOKORO_ARTIFACTS_DIR%\github\test-koko\sign_vsix.ps1

EXIT /b %ERRORLEVEL%