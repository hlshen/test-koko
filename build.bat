@echo off
setlocal

ECHO Building VSCode...

ksigntool sign GOOGLE_EXTERNAL /v /debug /t http://timestamp.digicert.com %KOKORO_ARTIFACTS_DIR%\github\test-koko\fdc-latest.vsix

signtool verify /pa /all %KOKORO_ARTIFACTS_DIR%\github\test-koko\fdc-latest.vsix

EXIT /b %ERRORLEVEL%