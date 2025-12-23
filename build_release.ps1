# build_release.ps1

Write-Host "🚀 Starting Release Build Process..." -ForegroundColor Cyan

$rootDir = Get-Location
$frontendDir = "$rootDir\frontend"
$landingDir = "$rootDir\landing-page"
$downloadsDir = "$landingDir\public\downloads"

# 1. Clean/Create downloads directory
if (Test-Path $downloadsDir) {
    Remove-Item $downloadsDir -Recurse -Force
}
New-Item -ItemType Directory -Path $downloadsDir | Out-Null
Write-Host "✅ Created downloads directory: $downloadsDir" -ForegroundColor Green

# 2. Build Windows Release
Write-Host "📦 Building Windows Release..." -ForegroundColor Yellow
Push-Location $frontendDir
$prodApiUrl = "https://waterpulse-backend-w2ywvfxxqq-ew.a.run.app/api/v1"
flutter build windows --release --dart-define=API_BASE_URL=$prodApiUrl
if ($LASTEXITCODE -ne 0) {
    Write-Error "Windows build failed!"
    Pop-Location
    exit 1
}

# 3. Zip Windows Build
Write-Host "🗜️ Zipping Windows Build..." -ForegroundColor Yellow
$windowsBuildDir = "$frontendDir\build\windows\x64\runner\Release"
$zipPath = "$downloadsDir\WaterPulse-Windows.zip"

# Rename exe if needed (default is usually project name or frontend.exe)
if (Test-Path "$windowsBuildDir\frontend.exe") {
    Rename-Item "$windowsBuildDir\frontend.exe" "$windowsBuildDir\WaterPulse.exe"
}

Compress-Archive -Path "$windowsBuildDir\*" -DestinationPath $zipPath -Force
Write-Host "✅ Created Windows Zip: $zipPath" -ForegroundColor Green

# 4. Build Android APK (Optional, un-comment if needed, skipping to save time as UI focuses on Windows)
# Write-Host "📱 Building Android Release..." -ForegroundColor Yellow
# flutter build apk --release
# Copy-Item "$frontendDir\build\app\outputs\flutter-apk\app-release.apk" "$downloadsDir\WaterPulse.apk"
# Write-Host "✅ Created Android APK" -ForegroundColor Green

Pop-Location

Write-Host "🎉 All done! Artifacts are in $downloadsDir" -ForegroundColor Cyan
