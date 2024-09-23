<#
  This script signs .vsix files as part of the Cloud Code for VSCode release process.
  NOTE: This file can only be invoked as part of a child job due to its reliance on
  $KOKORO_GFILE_DIR. This is currently achieved with Rapid workflow chaining.
#>

# Declare constants
$certFilePath = 'C:\certfile.p7b'
$shred = 'C:\cygwin64\bin\shred.exe'
$timeStamp = 'http://timestamp.digicert.com'
$vsixSignTool = "$Env:KOKORO_ARTIFACTS_DIR\piper\google3\googleclient\kokoro\windows_manual_signing\vsixsigntool.exe"

# Verify VSIX file exists and there is only one
$vsixPath = "$Env:KOKORO_ARTIFACTS_DIR\github\test-koko\fdc-latest.vsix"
if ($vsixPath -eq $null) {
  Write-Error 'No vsix found! Abandoning sign.'
  exit 1
}
if ($vsixPath.count -ne 1) {
  Write-Error 'More than one Cloud Code vsix found! Abandoning sign.'
  exit 1
}
Write-Host "Cloud Code vsix found at $vsixPath"

# Search the certificate store for keys that match Google subject name and throw error if we find
# more/less than one.
$certList = Get-ChildItem -Path cert:\CurrentUser -recurse | Where-Object { $_.subject -match 'Google' }
if ($certList.count -lt 1) {
  Write-Error 'No certificate found! Abandoning sign.'
  exit 1
}
$cert = $certList | Select-Object -first 1

$keyContainerName = $cert.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
$csp = 'CurrentUser\My'
# Export the public key to a .p7b certfile
Export-Certificate -Cert $cert -FilePath $certFilePath -Type p7b
if (!($?)) {
  Write-Error 'Exporting certificate file failed! Abandoning sign.'
  exit 1
}

# Signs the VSIX
# This replicates the functionality of `%SIGNTOOL% sign /v /tr http://timestamp.digicert.com /n "Google" /a /fd sha256 /td sha256 <files...>`
# from the Kokoro code signing documentation at https://g3doc.corp.google.com/devtools/kokoro/g3doc/userdocs/windows/signing.md
Invoke-Expression "& $vsixSignTool sign /f $certFilePath /csp $csp /k $keyContainerName /tr $timeStamp /fd sha256 /td sha256 /v $vsixPath"
$scriptExitCode = $LastExitCode

# Shred the certfile
Invoke-Expression "& $shred -u -f $certFilePath"

# Move the newly-signed vsix to the artifacts directory for upload if successfully signed
if ($scriptExitCode -eq 0) {
  Copy-Item -Path "$Env:KOKORO_GFILE_DIR\*" -Destination "$Env:KOKORO_ARTIFACTS_DIR\package\" -Recurse
}

exit $scriptExitCode