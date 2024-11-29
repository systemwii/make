# Make

Welcome to systemwii's Make rules setup. Consult <https://makefiletutorial.com/> if you ever get stuck with this stuff.

## Make Configuration

You can set the variable **RULESDIR** to point to the rules folder of this repository. Clone this repository, and either add it as a submodule to your repository and set RULESDIR to point to it directly, or install it with `make install`, which replaces the entire contents of `$(DEVKITPPC)/rules` with this rules folder, and then set RULESDIR TO `$(DEVKITPPC)/rules`. Original DevkitPPC rules won't be affected by installing these, since they live scattered around `$(DEVKITPPC)/`.

With this set up, you can make a copy of a Makefile from any systemwii project and use it with the instructions below.

## Available Variables

> [!WARNING]  
> You can't put a comment on the same line as setting a variable else Make will include all the spaces before the # in the variable (lol).

All directories are relative to the Makefile being executed.

### Target

**TARGET**: The name of the output.

**TYPE**: The output's type. Options:
- `dol`: A final application binary, in .dol format. This will also generate a .elf binary, in the cache folder.
- `dol+elf`: As above but with both the .dol and .elf in the build folder.
- `a`: An archive for a static library, for linking in outside applications.

**PLATFORM**: The target platform settings to apply (options: `wii`, `gamecube`).

**BUILD**: The directory in which to place the output.

**CACHE**: The directory in which to place generated intermediate files.

### Sources

All of these are space-separated lists.

**SRCS**: Folders containing source files to use.

**SRCEXTS**: Extensions with which to filter the source folders (in the format `.cpp`). All files of these extensions will be included.

**BINS**: Folders containing binary data to inject into the output.

**BINEXTS**: Extensions with which to filter the binary data folders (in the format `.jpg`). All files of these extensions will be included.

**INCLUDES**: Directories for the compiler to search for .h header files. libogc headers and <CACHE>/data are automatically included (see above for the definition of CACHE).

**LIBS** Libraries to link with. These are specified verbatim as flags to the linker (look up `ld` for the format), and the libraries must be available in the two following search path variables. libogc libraries are automatically included.

**LIBDIRSBNDLE**: Search paths for bundled libraries: files matching `/include/*.h` and `/lib/*.a` in a folder specified here are included.

**LIBDIRSLOOSE**: Search paths for standalone `*.a` files.

### Flags

These are specified with `=` rather than `:=`, which means they are templates that will be substituted when called rather than when defined.

* **CFLAGS**: flags for the C compiler.
* **CXXFLAGS**: flags for the C++ compiler.
* **ASFLAGS**: flags for the assembler.
* **LDFLAGS**: flags for the linker.
* **ARFLAGS**: flags for the archiver (.a file generator).

INCLUDES, LIBS, LIBDIRSBNDLE and LIBDIRSLOOSE are automatically passed to the relevant tools. MACHDEP is defined in rules/platform.mk.

## Make Arguments

This make setup allows you to run `make` in any folder with a Makefile in your repository or sub-repositories. `make build` (or `make` by itself) builds the repository, and `make clean` deletes the built files. The default behaviour is to recurse into any nested subfolders that have Makefiles in them or in any subfolder (i.e. an additional depth of 1 or 2). Recursion can be disabled by passing `E=1` to make. Verbose mode can be enabled by passing `V=1` to make; it logs every toolchain command call, as well as locations of source and object files.

You're encouraged to read thru the Make rules setup and edit or override anything you wish to; installing the rules allows you to avoid having to specify their location each time and have an unchanging version; including them by submodule allows you to make instant changes to them as you work.

Add extra post-build targets, such as `install` to package your output, after any include lines in your main Makefile, so that it doesn't take precedence over the default `make` target (`make build`).
