## Prerequisites
- [CMake](https://cmake.org/download/)
- [Ninja](https://github.com/ninja-build/ninja/releases) <span style="color:gray">(don't forget to add the folder with ninja.exe to PATH)</span>
- [Android Studio with NDK](https://developer.android.com/studio)

## Set environment variables
ANDROID_NDK - path to NDK in Android Studio (e.g. `C:/Users/Alex/AppData/Local/Android/Sdk/ndk/27.1.12297006`)

## Build any library (PowerShell)
1. Copy the build script to the library folder (e.g. `build_lib_png.ps1` to the `libpng` folder)
2. Replace the necessary variables in the copied script (e.g. `$libPngBaseDir`, `$libFreetypeBaseDir`)
3. If needed - change the necessary options in the cmake arguments (where cmake -D...)
4. Run the script
```powershell
> ./build_lib_png.ps1
```
