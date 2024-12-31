# this (recursion-free) script builds one folder
.SUFFIXES:	# clears the implicit built-in rules
include $(RULESDIR)/tools.mk

### 1 | flags to be passed to compiler/linker
# these are substituted into recipes.mk, so you cannot rename variables
INCLUDE  := $(foreach dir, $(LIBDIRSBNDLE), -I $(dir)/include) \
			$(foreach dir, $(INCLUDES) $(SRCS), -iquote $(dir)) \
			-I $(LIBOGC)/include -I $(CACHE)/data
LIBPATHS := $(foreach dir, $(LIBDIRSBNDLE), -L $(dir)/lib) \
			$(foreach dir, $(LIBDIRSLOOSE), -L $(dir)) \
			-L $(LIBOGC)/lib/$(subst gamecube,cube,$(PLATFORM))

LD 		 := $(if $(findstring cpp,$(SRCEXTS)),$(CXX),$(CC))
DEPSDIR  := $(CACHE)
ifeq ($V, 1)
$(info )
$(info LOGC | $(LIBOGC))
$(info C*   | $(INCLUDE))
$(info LD   | $(LIBPATHS) $(LIBS))
endif

### 2 | source file enumeration
VPATH := $(SRCS) $(BINS) # built-in variable specifying search locations for prerequisites
# files are found by dir/*.*, then filtered by a list of extensions ("%" must be prepended to each extension)
SRCFILES := $(foreach dir, $(SRCS), $(filter $(foreach ext, $(SRCEXTS), %$(ext)), $(wildcard $(dir)/*.*)))
BINFILES := $(foreach dir, $(BINS), $(filter $(foreach ext, $(BINEXTS), %$(ext)), $(wildcard $(dir)/*.*)))
SRCOFILES:= $(foreach file, $(SRCFILES), $(CACHE)/$(notdir $(basename $(file))).o)
BINOFILES:= $(foreach file, $(BINFILES), $(CACHE)/data/$(notdir $(file).o))
ifeq ($V, 1)
$(info src  | $(SRCFILES))
$(info srco | $(SRCOFILES))
$(info bin  | $(BINFILES))
$(info bino | $(BINOFILES))
endif

### 3 | recipes
# syntax is "target: dependencies", meaning target *demands* dependencies
# each rule constructs targets in series, from all dependencies simultaneously
# once the demands are met (i.e. the files exist), the indented block below is run in a shell
# dependencies are recursed starting from the target passed to make, or
# the first in the file (after includes are resolved) if just "make" is called

# production of .elf / .a (using linker) depends on objects and included libraries
LINKDEPS := $(BINOFILES) $(SRCOFILES) \
			$(foreach dir, $(LIBDIRSBNDLE), $(wildcard $(dir)/lib/*.a)) \
			$(foreach dir, $(LIBDIRSLOOSE), $(wildcard $(dir)/*.a))

# output rules
ifeq ($(TYPE), dol+elf)
$(BUILD)/$(TARGET).dol		:	$(BUILD)/$(TARGET).elf
$(BUILD)/$(TARGET).elf		:	$(LINKDEPS)
endif
ifeq ($(TYPE), dol)
$(BUILD)/$(TARGET).dol		:   $(CACHE)/$(TARGET).elf
$(CACHE)/$(TARGET).elf		:	$(LINKDEPS)
endif
ifeq ($(TYPE), bin)
$(BUILD)/$(TARGET).bin		:   $(CACHE)/$(TARGET).elf
$(CACHE)/$(TARGET).elf		:	$(LINKDEPS)
endif
ifeq ($(TYPE), a)
$(BUILD)/lib$(TARGET).a		:	$(LINKDEPS)
endif
ifeq ($(TYPE), a+h)
$(BUILD)/lib/lib$(TARGET).a	:   $(LINKDEPS) $(BUILD)/include/$(TARGET).h
endif

# extra dependency enforcement
$(SRCOFILES): $(BINOFILES)	# some SRCOFILES include some BINOFILES
-include $(SRCOFILES:.o=.d) # "-" suppresses errors
# ^ compiler-generated rules connecting objects to source + headers (including library ones)

# commands to generate files
include $(RULESDIR)/recipes.mk

# delete generated files and any empty folders between them and the root
clean:
	@rm -rf $(BUILD) $(CACHE)
	@rmdir -p $(dir $(BUILD) $(CACHE)) 2>/dev/null || true
