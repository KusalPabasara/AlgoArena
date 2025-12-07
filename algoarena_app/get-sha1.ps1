# PowerShell script to get SHA-1 fingerprint for Android
# Run this script from the algoarena_app directory

Write-Host "🔍 Getting SHA-1 Fingerprint for Google Sign-In..." -ForegroundColor Cyan
Write-Host ""

# Try to find keytool in common locations
$keytoolPaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "C:\Program Files\Java\jdk-*\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "$env:ANDROID_HOME\jre\bin\keytool.exe"
)

$keytool = $null
foreach ($path in $keytoolPaths) {
    $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
    if ($resolved) {
        $keytool = $resolved[0].Path
        break
    }
}

if (-not $keytool) {
    Write-Host "❌ keytool not found. Trying alternative method..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Alternative: Use Android Studio" -ForegroundColor Cyan
    Write-Host "1. Open Android Studio" -ForegroundColor White
    Write-Host "2. Click Gradle (right panel)" -ForegroundColor White
    Write-Host "3. Navigate: app → Tasks → android → signingReport" -ForegroundColor White
    Write-Host "4. Double-click signingReport" -ForegroundColor White
    Write-Host "5. Copy SHA-1 from output" -ForegroundColor White
    Write-Host ""
    exit
}

$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (-not (Test-Path $keystorePath)) {
    Write-Host "❌ Debug keystore not found at: $keystorePath" -ForegroundColor Red
    Write-Host "   Run 'flutter build apk' first to generate it." -ForegroundColor Yellow
    exit
}

Write-Host "📦 Keystore found: $keystorePath" -ForegroundColor Green
Write-Host ""
Write-Host "🔑 SHA-1 Fingerprint:" -ForegroundColor Cyan
Write-Host ""

& $keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android | Select-String "SHA1"

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Copy the SHA-1 value above (the hex string)" -ForegroundColor White
Write-Host "2. Go to Firebase Console: https://console.firebase.google.com/" -ForegroundColor White
Write-Host "3. Select project: algoarena-a3d46" -ForegroundColor White
Write-Host "4. Project Settings → Your apps → Android app" -ForegroundColor White
Write-Host "5. Click 'Add fingerprint' and paste SHA-1" -ForegroundColor White
Write-Host "6. Download updated google-services.json" -ForegroundColor White
Write-Host "7. Replace android/app/google-services.json" -ForegroundColor White
Write-Host "8. Rebuild app: flutter clean && flutter run" -ForegroundColor White
Write-Host ""

