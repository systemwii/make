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
# -r: relocatable linking (output can be fed back into linker for incremental build)
# -g: enables debugging in gcc (not used by ld)
# -Wl: passes thru arguments to ld:
#      -Map: outputs a link map to a file
#      --no-gc-sections: disables garbage collection of symbols (needed by -r)
# -D: defines macro by name (with value 1)
# -m: machine-dependent options
# -L: specifies folders to search for libraries (*.a)
# -l: specifies libraries by name to find in -L folders and link to the project
# -o: output file
define link_rule
	$(SILENTMSG) [o → elf] [\*.o] → $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)$(LD) $(BINOFILES) $(SRCOFILES) $(LDFLAGS) $(MACHDEP) $(LIBPATHS) $(LIBS) -o $@
endef
$(BUILD)/%.elf: | $(BUILD)
	$(link_rule)
$(CACHE)/%.elf: | $(CACHE)
	$(link_rule)


# --- archiver ---
# c - creates archive
# r - adds members by replacement (rather than appending)
# s - writes an index (declaring its members to the linker)
# we call the linker to link in sublibraries, then archive the result

define archive_rule
	$(SILENTMSG) [o → a] [\*.o] → $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)rm -f $@
	$(SILENTCMD)$(LD) -r $(BINOFILES) $(SRCOFILES) $(LDFLAGS) $(LIBPATHS) $(LIBS) -o $(subst .a,.o,$@)
	$(SILENTCMD)$(AR) $(ARFLAGS) $@ $(subst .a,.o,$@)
	@echo
endef
$(BUILD)/lib/%.a:						# bundled libs
	@mkdir -p $(BUILD)/lib
	$(archive_rule)
$(BUILD)/%.a: | $(BUILD)				# loose libs
	$(archive_rule)

$(BUILD)/include/%.h: %.h				# bundled libs
	@mkdir -p $(BUILD)/include
	$(SILENTMSG) [h → h] $< → $@
	@cp $< $@


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
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(CXXFLAGS) $(MACHDEP) $(INCLUDE) -c $< -o $@" $<
	$(SILENTCMD)$(CXX) -c -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(CXXFLAGS) $(MACHDEP) $(INCLUDE) $< -o $@ $(ERROR_FILTER)

# c
$(CACHE)/%.o: %.c | $(CACHE)
	$(SILENTMSG) [c → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "-c $(CPPFLAGS) $(CFLAGS) $(MACHDEP) $(INCLUDE) $< -o $@" $<
	$(SILENTCMD)$(CC) -c -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(CFLAGS) $(MACHDEP) $(INCLUDE) $< -o $@ $(ERROR_FILTER)

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
