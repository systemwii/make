# Make

Welcome to systemwii's Make rules setup. Consult <https://makefiletutorial.com/> if you ever get stuck with this stuff.

## Make Configuration

To start, clone a copy of either the whole [template repository](https://github.com/systemwii/template) (which becomes your project repo), or just copy its Makefile into an existing project.

Either include it by submodule or (clone and) install it to your devkitPro installation as below. Installing the rules lets you have an unchanging version at a global path, while including them by submodule allows you to make instant changes to them as you work.

### 1. Submodule

From your project repository, run this to add this repo as a submodule:
```bash
git submodule add https://github.com/systemwii/make.git lib/make
```
Then set RULESDIR in your project's Makefile to point to it:
```makefile
RULESDIR	:=	lib/make/rules
```
To update it, run:
```bash
cd lib/make && git pull && cd ../..
```

### 2. Install
Clone this repository, then from inside it, rename `Makefile_` to `Makefile`, then run install:
```bash
mv Makefile_ Makefile
make install
```
This replaces the entire contents of `$(DEVKITPPC)/rules` with the rules folder here. The Makefile is called `Makefile_` by default to avoid it being detected and run as part of the submodule setup above (which slows down builds but is otherwise harmless).

Next, set RULESDIR in your project's Makefile to point to the installation:
```
RULESDIR	:=	$(DEVKITPPC)/rules
```
Original DevkitPPC rules won't be affected by installing these, since they live scattered around `$(DEVKITPPC)/`.

## Available Variables

Use your project's Makefile with these instructions.

> [!WARNING]  
> You can't put a comment on the same line as setting a variable else Make will include all the spaces before the # in the variable (lol).

All directories are relative to the Makefile being executed. Variables specified with `=` rather than `:=` are templates that will be substituted when called rather than when defined.

### Target

**TARGET**: The name of the output.

**TYPE**: The output's type. Options:
- `dol`: A final application binary, in .dol format. This will also generate a .elf binary, in the cache folder.
- `dol+elf`: As above but with both the .dol and .elf in the build folder.
- `bin`: A raw binary, converted from an .elf binary (generated in the cache folder) with `objcopy -O binary`.
- `a`: An archive for a static library (named `lib<TARGET>.a`), for linking in outside applications (e.g. with the LIBDIRSLOOSE variable here).
- `a+h`: An archive for a static library, bundled with its header (to `lib/lib<TARGET>.a` and `include/<TARGET>.h`), for linking in outside applications (e.g. with the LIBDIRSBNDLE variable here).
- If left blank, Make will compile the project into object files but not link them into an output.

**PLATFORM**: The target platform settings to apply (options: `wii`, `gamecube`).

**BUILD**: The directory in which to place the output.

**CACHE**: The directory in which to place generated intermediate files.

### Sources

All of these are space-separated lists.

**SRCS**: Folders containing source files to use.

> [!NOTE]
> If you put a sub-repo's root here, build/cache folders may fail to be generated because Make detects them (via VPATH) in the sub-repo. This can be worked around by changing BUILD/CACHE in either repo or making the folders yourself.

**SRCEXTS**: Extensions with which to filter the source folders (in the format `.cpp`). All files of these extensions will be included.

**BINS**: Folders containing binary data to inject into the output.

**BINEXTS**: Extensions with which to filter the binary data folders (in the format `.jpg`). All files of these extensions will be included.

**LIBS** Libraries to link with. These are specified verbatim as flags to the linker (look up `ld` for the format), and any local libraries must be available in the two following search path variables. Installed libraries, such as libogc and [libm](https://en.wikipedia.org/wiki/C_standard_library#Linking,_libm), are automatically available.

*[libogc libraries](https://github.com/devkitPro/libogc):*
- *(Wii/GameCube)*: -logc -lmad -ldb -lfat -ltinysmb -lgxflux -lmodplay -liso9660 -lasnd -laesnd
- *(Wii)*: -lwiiuse -lbte -lwiikeyboard -ldi
- *(GameCube)*: -lbba

> [!IMPORTANT]
> If a library you list here requires another you list here, you must list the requirer **before** the requiree.

> [!TIP]  
> To optimise the sizes of all outputs and build speed, it's best to specify here local libraries for the immediate projects that use them, and installed libraries (like libogc ones) only in the top-level project. Ideally, every library is specified only once in a build tree, tho it's not always possible.

```mermaid
graph TD;
    X["[appX]<br>LIBS := -libY -logc"]-->Y;
    Y["[libY]<br>LIBS := -libZ"]-->Z;
    Z["[libZ]<br>LIBS := "]

    A["[AppA]<br>LIBS := -libB -libC -logc"]-->B;
    A-->C;
    B["[libB]<br>LIBS := -libD"]-->D;
    C["[libC]<br>LIBS := -libD"]-->D;
    D["[libD]<br>LIBS :="]
```

**LIBDIRSBNDLE**: Search paths for bundled libraries: files matching `/include/*.h` and `/lib/*.a` in a folder specified here are included.

**LIBDIRSLOOSE**: Search paths for standalone `*.a` files (search is not recursive).

**INCLUDES**: Search paths for `*.h` header files (search is not recursive). \<SRCS\>, libogc headers and \<CACHE\>/data are automatically included (see above for the definitions of SRCS and CACHE).

**LIBOGC**: The folder where libogc (or a fork) is installed: a good starting point is to use `$(DEVKITPRO)/libogc` when targeting the Wii in PLATFORM, and to [install](https://github.com/extremscorner/libogc2?tab=readme-ov-file#installing) and use `$(DEVKITPRO)/libogc2` when targeting the GameCube.

### Flags

* **CFLAGS**: flags for the C compiler.
* **CXXFLAGS**: flags for the C++ compiler.
* **ASFLAGS**: flags for the assembler.
* **LDFLAGS**: flags for the linker.
* **ARFLAGS**: flags for the archiver (.a file generator).

INCLUDES, LIBS, LIBDIRSBNDLE and LIBDIRSLOOSE are automatically passed to the relevant tools. See rules/recipes.mk for an outline of what the flags mean.

> [!WARNING]  
> MACHDEP (defined in rules/platform.mk) used to be specified here, but is now auto-passed in rules/recipes.mk for all compiles and application links, and you are strongly advised to not reinclude it. Because if you set `$(MACHDEP)` in LDFLAGS for a library link, this will cause MACHDEP-related symbols to be silently included several times in any final application using it 👻, which can cause a black-screen crash on start with no feedback 💀. So don't!

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

There's an additional post-build option, to run after the build:
- `make run`: if the build produces a .dol executable, this sends it to the Homebrew Channel over your local network and runs it (with AHB access forced on). To configure your Wii's IP address, use `export WIILOAD=tcp:192.168.1.xx`, substituting your Wii's local IP address, which you can set up via a DHCP reservation in your router's settings.

You're encouraged to read thru the Make rules setup and edit or override anything you wish to. Add extra post-build targets, such as `dist` to package your output, after any include lines in your main Makefile, so that they don't take precedence over the default `make` target (`make build`).
