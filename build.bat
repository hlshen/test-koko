@echo off
setlocal

ECHO Starting vsix code signing...

PowerShell -File %KOKORO_ARTIFACTS_DIR%\piper\google3\third_party\cloudcode\vscode\.kokoro\sign_vsix.ps1

EXIT /b %ERRORLEVEL%