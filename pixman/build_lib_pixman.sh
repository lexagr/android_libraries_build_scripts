#!/bin/bash

# Path to Android NDK
# export MINGW_ANDROID_NDK=/c/Users/Alex/AppData/Local/Android/Sdk/ndk/27.1.12297006
export NDK_DIR="$ANDROID_NDK"
# export NDK_DIR="$MINGW_ANDROID_NDK"

CPU_FEATURES_PATH="$NDK_DIR/sources/android/cpufeatures"

# Android API level
API_LEVEL=21

# Create build directory
BUILD_DIR=$PWD/build
mkdir -p $BUILD_DIR

# Array of architectures
ARCHS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# Function to set up build parameters
setup_environment() {
    case $1 in
        "armeabi-v7a")
            TARGET_HOST=armv7a-linux-androideabi
            ARCH=arm
            CPU=armv7-a
            TRIPLE=arm-linux-androideabi
            SYSROOT=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/sysroot
            CC=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/armv7a-linux-androideabi$API_LEVEL-clang.cmd
            ;;
        "arm64-v8a")
            TARGET_HOST=aarch64-linux-android
            ARCH=arm64
            CPU=armv8-a
            TRIPLE=aarch64-linux-android
            SYSROOT=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/sysroot
            CC=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android$API_LEVEL-clang.cmd
            ;;
        "x86")
            TARGET_HOST=i686-linux-android
            ARCH=x86
            CPU=i686
            TRIPLE=i686-linux-android
            SYSROOT=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/sysroot
            CC=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/i686-linux-android$API_LEVEL-clang.cmd
            ;;
        "x86_64")
            TARGET_HOST=x86_64-linux-android
            ARCH=x86_64
            CPU=x86-64
            TRIPLE=x86_64-linux-android
            SYSROOT=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/sysroot
            CC=$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/x86_64-linux-android$API_LEVEL-clang.cmd
            ;;
        *)
            echo "Unknown architecture: $1"
            exit 1
            ;;
    esac

    mkdir -p $BUILD_DIR/$1
    mkdir -p $BUILD_DIR/dist/$1

    PREFIX=$BUILD_DIR/dist/$1
    COMMON_FLAGS="--sysroot=$SYSROOT"
    CFLAGS="$COMMON_FLAGS"
    LDFLAGS="$COMMON_FLAGS"

    # Meson cross-file configuration
    CROSS_FILE=$BUILD_DIR/$1-crossfile.txt

    cat > $CROSS_FILE <<EOL
[binaries]
c = '$CC'
ar = '$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-ar'
strip = '$NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-strip'
pkgconfig = 'pkg-config'

[properties]
needs_exe_wrapper = true
sys_root = '$SYSROOT'
c_args = ['$CFLAGS']
c_link_args = ['$LDFLAGS']
pkg_config_libdir = '$PREFIX/lib/pkgconfig'

[host_machine]
system = 'android'
cpu_family = '$ARCH'
cpu = '$CPU'
endian = 'little'
EOL
}

build_library() {
    cd $BUILD_DIR/$ARCH_NAME

    meson setup --cross-file=$CROSS_FILE --prefix=$PREFIX --buildtype=release \
        -Dlibpng=disabled -Dgtk=disabled -Dopenmp=disabled -Dtests=disabled \
        -Dcpu-features-path=$CPU_FEATURES_PATH -Ddefault_library=static ../../

    meson compile
    meson install

    cd ../..
}

# Main loop over architectures
rm -rf $BUILD_DIR
for ARCH_NAME in "${ARCHS[@]}"
do
    echo "===================================="
    echo "Building for architecture: $ARCH_NAME"
    echo "===================================="

    setup_environment $ARCH_NAME
    build_library

    echo "Build for $ARCH_NAME completed."
done

echo "All builds completed."
