#---------------------------------------------------------------------------------
# make sure we have bash on OSX
#---------------------------------------------------------------------------------
UNAME_S	:=	$(shell uname -s)

ifneq (,$(findstring Darwin,$(UNAME_S)))
	export SHELL=/bin/bash
endif

#---------------------------------------------------------------------------------
# path to tools
#---------------------------------------------------------------------------------
DEVKITPATH      =   $(shell echo "$(DEVKITPRO)" | sed -e 's/^\([a-zA-Z]\):/\/\1/')
export PATH	    :=	$(DEVKITPATH)/tools/bin:$(DEVKITPATH)/devkitPPC/bin:$(PATH)

#---------------------------------------------------------------------------------
# path to portlibs
#---------------------------------------------------------------------------------
PORTLIBS		:=	$(DEVKITPRO)/portlibs/$(PLATFORM) $(DEVKITPRO)/portlibs/ppc
export PATH		:=	$(addsuffix /bin,$(PORTLIBS)):$(PATH)

#---------------------------------------------------------------------------------
# the prefix on the compiler executables
#---------------------------------------------------------------------------------
PREFIX	:=	powerpc-eabi-

export AS		:=	$(PREFIX)as
export CC		:=	$(PREFIX)gcc
export CXX		:=	$(PREFIX)g++
export AR		:=	$(PREFIX)gcc-ar
export OBJCOPY	:=	$(PREFIX)objcopy
export STRIP	:=	$(PREFIX)strip
export NM		:=	$(PREFIX)gcc-nm
export RANLIB	:=	$(PREFIX)gcc-ranlib

ISVC=$(or $(VCBUILDHELPER_COMMAND),$(MSBUILDEXTENSIONSPATH32),$(MSBUILDEXTENSIONSPATH))

ifneq (,$(ISVC))
	ERROR_FILTER	:=	2>&1 | sed -e 's/\(.[a-zA-Z]\+\):\([0-9]\+\):/\1(\2):/g'
endif

#---------------------------------------------------------------------------------
# allow seeing compiler command lines with make V=1 (similar to autotools' silent)
#---------------------------------------------------------------------------------
ifeq ($(V),1)
    SILENTMSG := @echo && echo
    SILENTCMD := 
else
    SILENTMSG := @echo
    SILENTCMD := @
endif

#---------------------------------------------------------------------------------
# Generate compile commands
#---------------------------------------------------------------------------------
ifeq ($(GENERATE_COMPILE_COMMANDS),1)
    ADD_COMPILE_COMMAND := @/opt/devkitpro/tools/bin/generate_compile_commands
else
    ADD_COMPILE_COMMAND := @true
endif
