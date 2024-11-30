# Make

Welcome to systemwii's Make rules setup. Consult <https://makefiletutorial.com/> if you ever get stuck with this stuff.

## Make Configuration

You can set the variable **RULESDIR** to point to the rules folder of this repository. Clone this repository, and either:
1. add it as a submodule to your repository and set RULESDIR to point to it directly, or
2. install it with `make install`, which replaces the entire contents of `$(DEVKITPPC)/rules` with this rules folder, and then set RULESDIR TO `$(DEVKITPPC)/rules`. Original DevkitPPC rules won't be affected by installing these, since they live scattered around `$(DEVKITPPC)/`.

Installing the rules lets you have an unchanging version at a global path, while including them by submodule allows you to make instant changes to them as you work.

With this set up, you can make a copy of a Makefile from any systemwii project and use it with the instructions below.

## Available Variables

> [!WARNING]  
> You can't put a comment on the same line as setting a variable else Make will include all the spaces before the # in the variable (lol).

All directories are relative to the Makefile being executed. Variables specified with `=` rather than `:=` are templates that will be substituted when called rather than when defined.

### Target

**TARGET**: The name of the output.

**TYPE**: The output's type. Options:
- `dol`: A final application binary, in .dol format. This will also generate a .elf binary, in the cache folder.
- `dol+elf`: As above but with both the .dol and .elf in the build folder.
- `a`: An archive for a static library (named `lib<TARGET>.a`), for linking in outside applications (e.g. with the LIBDIRSLOOSE variable here).
- `a+h`: An archive for a static library, bundled with its header (to `lib/lib<TARGET>.a` and `include/<TARGET>.h`), for linking in outside applications (e.g. with the LIBDIRSBNDLE variable here).

**PLATFORM**: The target platform settings to apply (options: `wii`, `gamecube`).

**BUILD**: The directory in which to place the output.

**CACHE**: The directory in which to place generated intermediate files.

### Sources

All of these are space-separated lists.

**SRCS**: Folders containing source files to use.

**SRCEXTS**: Extensions with which to filter the source folders (in the format `.cpp`). All files of these extensions will be included.

**BINS**: Folders containing binary data to inject into the output.

**BINEXTS**: Extensions with which to filter the binary data folders (in the format `.jpg`). All files of these extensions will be included.

**LIBS** Libraries to link with. These are specified verbatim as flags to the linker (look up `ld` for the format), and the libraries must be available in the two following search path variables. libogc and [libm](https://en.wikipedia.org/wiki/C_standard_library#Linking,_libm) are automatically available.

*[libogc libraries](https://github.com/devkitPro/libogc):*
- *(Wii/GameCube)*: -logc -lmad -ldb -lfat -ltinysmb -lgxflux -lmodplay -liso9660 -lasnd -laesnd
- *(Wii)*: -lwiiuse -lbte -lwiikeyboard -ldi
- *(GameCube)*: -lbba

**LIBDIRSBNDLE**: Search paths for bundled libraries: files matching `/include/*.h` and `/lib/*.a` in a folder specified here are included.

**LIBDIRSLOOSE**: Search paths for standalone `*.a` files (search is not recursive).

**INCLUDES**: Search paths for `*.h` header files (search is not recursive). libogc headers and \<CACHE\>/data are automatically included (see above for the definition of CACHE).

### Flags

* **CFLAGS**: flags for the C compiler.
* **CXXFLAGS**: flags for the C++ compiler.
* **ASFLAGS**: flags for the assembler.
* **LDFLAGS**: flags for the linker.
* **ARFLAGS**: flags for the archiver (.a file generator).

INCLUDES, LIBS, LIBDIRSBNDLE and LIBDIRSLOOSE are automatically passed to the relevant tools. MACHDEP is defined in rules/platform.mk. See rules/recipes.mk for an outline of what the flags mean.

## Make Arguments

This make setup allows you to run `make` in any folder with a Makefile in your repository or sub-repositories.

- `make build` (or `make` by itself) builds the repository, and
- `make clean` deletes the built files.

The default behaviour is to recurse into any nested subfolders that have Makefiles in them or in any subfolder (i.e. an additional depth of 1 or 2). You can also pass these arguments:

- `E=1`: disables recursion (acts on only the current folder);
- `V=1`: enables verbose mode, which logs every toolchain command call, as well as locations of source and object files.

```bash
make build E=1 V=1
```

You're encouraged to read thru the Make rules setup and edit or override anything you wish to. Add extra post-build targets, such as `dist` to package your output, after any include lines in your main Makefile, so that they don't take precedence over the default `make` target (`make build`).
