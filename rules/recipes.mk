# recipe automatic variables:
# $@ - the current target (of the series specified on the left of the colon)
# $< - the first dependency
# $^ - all dependencies (as a space-seperated list)
# note that $^ restricts you to using dependencies compatible with the recipe commands

# some tool flags are explained below; for reference, look up "man gcc", "man ld", etc.

# --- output tools ---

$(BUILD)/%.dol: | $(BUILD)
	$(SILENTMSG) [elf → dol] → $@
	$(SILENTCMD)elf2dol $< $@
	@echo

$(BUILD)/%.tpl: | $(BUILD)
	$(SILENTMSG) [scf → tpl] → $@
	$(SILENTCMD)gxtexconv -s $< -d $(DEPSDIR)/$*.d -o $@


# --- linker ---
# using ld from the toolchain doesn't work for some reason, so we call gcc/g++
# [inputs]: object (.o) files to link
# -g: enables debugging in gcc (not used by ld)
# -Wl: passes thru arguments to ld:
#      -Map: outputs a link map to a file
# -D: defines macro by name (with value 1)
# -m: machine-dependent options
# -L: specifies folders to search for libraries (*.a)
# -l: specifies libraries by name to find in -L folders and link to the project
# -o: output file

$(BUILD)/%.elf: | $(BUILD)
	$(SILENTMSG) [o → elf] → $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)$(LD) $^ $(LDFLAGS) $(LIBPATHS) $(LIBS) -o $@
$(CACHE)/%.elf: | $(CACHE)
	$(SILENTMSG) [o → elf] → $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)$(LD) $^ $(LDFLAGS) $(LIBPATHS) $(LIBS) -o $@


# --- archiver ---
# c - creates archive
# r - adds members by replacement (rather than appending)
# s - writes an index (declaring its members to the linker)

$(BUILD)/%.a: | $(BUILD)
	$(SILENTMSG) [o → a] → $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)rm -f $@
	$(SILENTCMD)$(AR) $(ARFLAGS) $@ $^
	@echo


# --- compiler ---
# [inputs] source files to compile (extension matching template)
# -c compile/assemble to objects (*.o), without linking them
# -M*: set of flags instructing the preprocessor to output dependencies in make format to a file
# -g: enables debugging in gcc
# -save-temps: retains intermediate files (here, that excludes *.d and *.o)
# -O2: optimisation level 2 (can also use -Os to optimise for size at around O2 level)
# -W: toggles compiler warnings
# -D: defines macro by name (with value 1)
# -m: machine-dependent options
# -x: specifies a language for an input file
# -I: specifies folders to search for headers (*.h); can use -iquote to specify "" includes, excluding <>
# -o: output file

# c++
$(CACHE)/%.o: %.cpp | $(CACHE)
	$(SILENTMSG) [cpp → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(CXXFLAGS) $(INCLUDE) -c $< -o $@" $<
	$(SILENTCMD)$(CXX) -c -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(CXXFLAGS) $(INCLUDE) $< -o $@ $(ERROR_FILTER)

# c
$(CACHE)/%.o: %.c | $(CACHE)
	$(SILENTMSG) [c → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "-c $(CPPFLAGS) $(CFLAGS) $(INCLUDE) $< -o $@" $<
	$(SILENTCMD)$(CC) -c -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(CFLAGS) $(INCLUDE) $< -o $@ $(ERROR_FILTER)

# objective-c :eyes:
$(CACHE)/%.o: %.m | $(CACHE)
	$(SILENTMSG) [m → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "-c $(CPPFLAGS) $(OBJCFLAGS) $< -o $@" $<
	$(SILENTCMD)$(CC) -c -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(OBJCFLAGS) $< -o $@ $(ERROR_FILTER)

# assembly language
$(CACHE)/%.o: %.s | $(CACHE)
	$(SILENTMSG) [s → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "-c $(CPPFLAGS) $(ASFLAGS) $(INCLUDE) $< -o $@" $<
	$(SILENTCMD)$(CC) -c -MMD -MP -MF $(DEPSDIR)/$*.d -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) $(INCLUDE) $< -o $@ $(ERROR_FILTER)
$(CACHE)/%.o: %.S | $(CACHE)
	$(SILENTMSG) [s → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "-c $(CPPFLAGS) $(ASFLAGS) $(INCLUDE) $< -o $@" $<
	$(SILENTCMD)$(CC) -c -MMD -MP -MF $(DEPSDIR)/$*.d -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) $(INCLUDE) $< -o $@ $(ERROR_FILTER)

# injected binary data (using the bin2s tool)
$(CACHE)/data/%.o : % | $(CACHE)/data
	$(SILENTMSG) [b → o] $< → $@
	$(eval _tmpasm := $(shell mktemp))
	$(SILENTCMD)bin2s -a 32 -H `(echo $@ | tr . _ | sed "s/_o$$//")`.h $< > $(_tmpasm)
	$(SILENTCMD)$(CC) -c -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) $(_tmpasm) -o $@
	@rm $(_tmpasm)


# --- creates folders ---

$(BUILD) $(CACHE) $(CACHE)/data:
	@mkdir -p $@
