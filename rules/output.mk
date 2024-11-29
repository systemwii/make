#$(info >>>>> $(CURDIR) | 1 <<<<<)
.SUFFIXES:	# clears the implicit built-in rules
include $(RULESDIR)/tools.mk
include $(RULESDIR)/platform.mk

### 1 | flags to be passed to compiler/linker
# these are overrides of <platform>_rules, so you cannot rename variables
INCLUDE  := $(foreach dir, $(LIBLOCBUNDLE), -I $(dir)/include) \
			$(foreach dir, $(INCLUDES), -iquote $(dir)) \
			-I $(LIBOGC_INC) -I $(CACHE)/data
LIBPATHS := $(foreach dir, $(LIBLOCBUNDLE), -L $(dir)/lib) \
			$(foreach dir, $(LIBLOCLOOSE), -L $(dir)) \
			-L $(LIBOGC_LIB)

LD 		 := $(if $(findstring cpp,$(SRCEXTS)),$(CXX),$(CC))
DEPSDIR  := $(CACHE)
ifeq ($V, 1)
$(info )
$(info C*   | $(INCLUDE))
$(info LD   | $(LIBPATHS) $(LIBS))
endif

### 2 | source file enumeration
VPATH := $(SRCS) $(BINS) $(CACHE)
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
# syntax is "product: dependencies", newlines have extra steps)
# first rule in this file is first checked, then dependencies recursed

# output rules
ifeq ($(TYPE), dol+elf)
$(BUILD)/$(TARGET).dol  :   $(BUILD)/$(TARGET).elf
$(BUILD)/$(TARGET).elf  :   $(BINOFILES) $(SRCOFILES)
endif
ifeq ($(TYPE), dol)
$(BUILD)/$(TARGET).dol  :   $(CACHE)/$(TARGET).elf
$(CACHE)/$(TARGET).elf  :   $(BINOFILES) $(SRCOFILES)
endif
ifeq ($(TYPE), a)
$(BUILD)/lib$(TARGET).a	:   $(BINOFILES) $(SRCOFILES)
endif

$(SRCOFILES): $(BINOFILES)

# compiler-generated dependency-test make targets (.d files)
-include $(SRCOFILES:.o=.d) # "-" suppresses errors

include $(RULESDIR)/recipes.mk

clean:
	@echo [clean] $(CURDIR)
	@rm -rf $(BUILD) $(CACHE)
	@find $(dir $(BUILD) $(CACHE)) -type d -empty -delete 2>/dev/null || true
