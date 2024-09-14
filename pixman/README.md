## Prerequisites
- [Meson](https://github.com/mesonbuild/meson/releases)
- [Ninja](https://github.com/ninja-build/ninja/releases)
- [Python 3.12](https://www.python.org/downloads/release/python-3124/)
- [<span style="color:gray">[OPTIONAL]</span> MSYS2 + mingw64](https://www.msys2.org/)

## MinGW setup
⚠️ Some packages may be missing (this is the first guide to the MinGW build process)
```bash
$ pacman -S base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-python \
mingw-w64-x86_64-python-pip \
mingw-w64-x86_64-pkg-config git wget tar xz
```

## Build (MinGW)
1. Copy the file `build_lib_pixman.sh` to the `pixman` folder
2. Run script
```bash
$ ./build_lib_pixman.sh
```

## Build (PowerShell)
1. Copy the file `build_lib_pixman.ps1` to the `pixman` folder
2. Run script
```powershell
> ./build_lib_pixman.ps1
```
