# MakeQemuWin

A makefile for building QEMU using msys2 on Windows.

A work continually in progress.

Motivation: Attempting to debug some complex ARM firmware on not-yet-ready hardware lead back to QEMU and emulation of Cortex M7 devices. Sadly all attempts to do this were thwarted by QEMU's inability to understand valid COM port filenames like `\\.\COM19` or the com0com generated `\\.\CNCA0`. Modifying QEMU code seemed inevitable. With the immediate corrollary being a requirement for simple, fast, and repeatable compilation on Windows hardware.

The core requirements are limited to:

1. A working msys2 installation (https://www.msys2.org/)
2. Cloning this repository to somewhere suitable i.e. `~/src/qemuw`

Run `make` to see this:

```
JEvans@I7 MINGW64 ~/src/MakeQemuWin
$ make
make clone: Get source tree into ../qemu
make setup: configure QEMU build. arm and aarch64 in this case
make build: runs make on QEMU source tree (../qemu)
make update: copies binaries to target folder (/r/apps/qemu9)
make msys: ensure pacman updates and installs build requirements
make nuke: delete all build artefacts, including directory and configuration ../buildcd ../qemu9
make install: copies built binaries and runtime DLLs etc. to target folder (/r/apps/qemu9)
```



Links and references:

Thanks and credit for getting things rolling: https://github.com/RceNinja/notes/blob/master/notes/build_qemu_with_enabled_hyper-v_acceleration_(whpx)_on_windows.md


