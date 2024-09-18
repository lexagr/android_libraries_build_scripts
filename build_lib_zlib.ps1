$abis = @("arm64-v8a", "x86_64", "x86", "armeabi-v7a")
$ndkPath = $env:ANDROID_NDK
$apiLevel = 21
$maxThreads = 10

Write-Host "NDK Path: $ndkPath" -ForegroundColor Green

foreach ($abi in $abis) {
    Write-Host "Building for $abi.." -ForegroundColor Blue
    $destinationDir = "./build/$abi"

    if (-not (Test-Path "$destinationDir")) {
        New-Item -Path "$destinationDir" -ItemType Directory
    }

    cmake -S . -B "$destinationDir" `
        -DCMAKE_TOOLCHAIN_FILE="$ndkPath\build\cmake\android.toolchain.cmake" `
        -DANDROID_ABI="$abi" `
        -DANDROID_PLATFORM="$apiLevel" `
        -DCMAKE_INSTALL_PREFIX="$destinationDir/install" `
        -GNinja

    cmake --build "$destinationDir" -- -j "$maxThreads"
    
    Write-Host "Installing $abi.." -ForegroundColor Blue
    cmake --build "$destinationDir" --target install
}
