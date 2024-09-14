# Define environment variables and constants
$NDK_DIR = $env:ANDROID_NDK
$CPU_FEATURES_PATH = "$NDK_DIR/sources/android/cpufeatures"
$API_LEVEL = 21
$START_DIR = "$PWD"
$BUILD_DIR = "$PWD/build"
$ARCHS = @("armeabi-v7a", "arm64-v8a", "x86", "x86_64")

Write-Host "NDK_DIR: $NDK_DIR" -ForegroundColor Green

# Clean and create build directory
Remove-Item -Recurse -Force -Path $BUILD_DIR -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $BUILD_DIR

# Dictionary for architecture-specific settings
$archConfigs = @{
    "armeabi-v7a"  = @{ ARCH = "arm"; CPU = "armv7-a"; TARGET = "armv7a-linux-androideabi"; TRIPLE = "arm-linux-androideabi" }
    "arm64-v8a"    = @{ ARCH = "arm64"; CPU = "armv8-a"; TARGET = "aarch64-linux-android"; TRIPLE = "aarch64-linux-android" }
    "x86"          = @{ ARCH = "x86"; CPU = "i686"; TARGET = "i686-linux-android"; TRIPLE = "i686-linux-android" }
    "x86_64"       = @{ ARCH = "x86_64"; CPU = "x86-64"; TARGET = "x86_64-linux-android"; TRIPLE = "x86_64-linux-android" }
}

# Function to set up environment and generate cross-file
function Setup-Environment {
    param ([string]$archName)

    $config = $archConfigs[$archName]
    if (-not $config) {
        throw "Unknown architecture: $archName"
    }

    $SYSROOT = "$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/sysroot"
    $CC = "$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/$($config.TARGET)$API_LEVEL-clang.cmd"
    $PREFIX = "$BUILD_DIR/dist/$archName"
    $CROSS_FILE = "$BUILD_DIR/$archName-crossfile.txt"

    # Create necessary directories
    New-Item -ItemType Directory -Force -Path "$BUILD_DIR/$archName"
    New-Item -ItemType Directory -Force -Path "$PREFIX"

    # Generate the Meson cross-file
    Set-Content -Path $CROSS_FILE -Value @"
[binaries]
c = '$CC'
ar = '$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-ar'
strip = '$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-strip'
pkgconfig = 'pkg-config'

[properties]
needs_exe_wrapper = true
sys_root = '$SYSROOT'
c_args = ['--sysroot=$SYSROOT']
c_link_args = ['--sysroot=$SYSROOT']
pkg_config_libdir = '$PREFIX/lib/pkgconfig'

[host_machine]
system = 'android'
cpu_family = '$($config.ARCH)'
cpu = '$($config.CPU)'
endian = 'little'
"@
}

# Function to build the library
function Build-Library {
    param ([string]$archName)

    $PREFIX = "$BUILD_DIR/dist/$archName"
    $CROSS_FILE = "$BUILD_DIR/$archName-crossfile.txt"

    # Set location for build and run Meson commands
    Set-Location "$BUILD_DIR/$archName"
    & meson setup --cross-file="$CROSS_FILE" --prefix="$PREFIX" --buildtype=release `
        -Dlibpng=disabled -Dgtk=disabled -Dopenmp=disabled -Dtests=disabled `
        -Dcpu-features-path="$CPU_FEATURES_PATH" -Ddefault_library=static "../../"
    & meson compile
    & meson install
}

# Main build loop for all architectures
foreach ($ARCH_NAME in $ARCHS) {
    Write-Host "===================================="
    Write-Host "Building for architecture: $ARCH_NAME"
    Write-Host "===================================="
    
    Setup-Environment -archName $ARCH_NAME
    Build-Library -archName $ARCH_NAME
    
    Write-Host "Build for $ARCH_NAME completed."
}

Write-Host "All builds completed."
Set-Location "$START_DIR"
