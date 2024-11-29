#---------------------------------------------------------------------------------
$(BUILD)/%.dol: | $(BUILD)
	$(SILENTMSG) [elf → dol] $@
	$(SILENTCMD)elf2dol $< $@
	@echo

#---------------------------------------------------------------------------------
$(BUILD)/%.tpl: | $(BUILD)
	$(SILENTMSG) [scf → tpl] $@
	$(SILENTCMD)gxtexconv -s $< -d $(DEPSDIR)/$*.d -o $@

#---------------------------------------------------------------------------------
$(BUILD)/%.elf: | $(BUILD)
	$(SILENTMSG) [o → elf] $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)$(LD) $^ $(LDFLAGS) $(LIBPATHS) $(LIBS) -o $@

#---------------------------------------------------------------------------------
$(CACHE)/%.elf: | $(CACHE)
	$(SILENTMSG) [o → elf] $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)$(LD) $^ $(LDFLAGS) $(LIBPATHS) $(LIBS) -o $@

#---------------------------------------------------------------------------------
$(BUILD)/%.a: | $(BUILD)
	$(SILENTMSG) [o → a] $@
	$(ADD_COMPILE_COMMAND) end
	$(SILENTCMD)rm -f $@
	$(SILENTCMD)$(AR) -rc $@ $^
	@echo

#---------------------------------------------------------------------------------
$(CACHE)/%.o: %.cpp | $(CACHE)
	$(SILENTMSG) [cpp → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(CXXFLAGS) -c $< -o $@" $<
	$(SILENTCMD)$(CXX) -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@ $(ERROR_FILTER)

#---------------------------------------------------------------------------------
$(CACHE)/%.o: %.c | $(CACHE)
	$(SILENTMSG) [c → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(CFLAGS) -c $< -o $@" $<
	$(SILENTCMD)$(CC) -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(CFLAGS) -c $< -o $@ $(ERROR_FILTER)

#---------------------------------------------------------------------------------
$(CACHE)/%.o: %.m | $(CACHE)
	$(SILENTMSG) [m → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(OBJCFLAGS) -c $< -o $@" $<
	$(SILENTCMD)$(CC) -MMD -MP -MF $(DEPSDIR)/$*.d $(CPPFLAGS) $(OBJCFLAGS) -c $< -o $@ $(ERROR_FILTER)

#---------------------------------------------------------------------------------
$(CACHE)/%.o: %.s | $(CACHE)
	$(SILENTMSG) [s → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(ASFLAGS) -c $< -o $@" $<
	$(SILENTCMD)$(CC) -MMD -MP -MF $(DEPSDIR)/$*.d -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) -c $< -o $@ $(ERROR_FILTER)

#---------------------------------------------------------------------------------
$(CACHE)/%.o: %.S | $(CACHE)
	$(SILENTMSG) [s → o] $< → $@
	$(ADD_COMPILE_COMMAND) add $(CC) "$(CPPFLAGS) $(ASFLAGS) -c $< -o $@" $<
	$(SILENTCMD)$(CC) -MMD -MP -MF $(DEPSDIR)/$*.d -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) -c $< -o $@ $(ERROR_FILTER)

#---------------------------------------------------------------------------------
$(CACHE)/data/%.o : % | $(CACHE)/data
	$(SILENTMSG) [b → o] $< → $@
	$(eval _tmpasm := $(shell mktemp))
	$(SILENTCMD)bin2s -a 32 -H `(echo $@ | tr . _ | sed "s/_o$$//")`.h $< > $(_tmpasm)
	$(SILENTCMD)$(CC) -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) -c $(_tmpasm) -o $@
	@rm $(_tmpasm)

#---------------------------------------------------------------------------------
$(BUILD) $(CACHE) $(CACHE)/data:
	@mkdir -p $@
