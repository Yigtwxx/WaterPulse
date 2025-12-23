$releaseDir = 'c:\Users\Asus\Desktop\WaterPulse\frontend\build\windows\x64\runner\Release'
$dest = 'c:\Users\Asus\Desktop\WaterPulse\landing-page\public\downloads'

# 1. Rename EXE
if (Test-Path "$releaseDir\frontend.exe") {
    Rename-Item "$releaseDir\frontend.exe" "$releaseDir\WaterPulse.exe"
}

# 2. Add README
$readmeContent = @"
WaterPulse - Installation Instructions
======================================

1. Right-click this zip file and choose "Extract All".
2. Open the extracted folder.
3. Double-click "WaterPulse.exe" to start the application.

No installation required!
"@
Set-Content -Path "$releaseDir\README.txt" -Value $readmeContent

# 3. Zip
if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force }
Compress-Archive -Path "$releaseDir\*" -DestinationPath "$dest\WaterPulse-Windows.zip" -Force

Write-Host "✅ Updated Release: WaterPulse.exe + README included."
