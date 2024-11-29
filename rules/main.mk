# recursive make
ifeq ($(E),1)						# this E flag ("exec") is set in leaf calls
include $(RULESDIR)/output.mk		# E=1: it calls the output (build) script
else								# E!=1: it recurses over subfolders

SUBDIRS := $(dir $(wildcard */*/Makefile */Makefile))# 1 or 2 levels deeper

SUBDIRSBUILD := $(addsuffix ~build,$(SUBDIRS))		# virtual targets representing build of subdir
build: $(SUBDIRSBUILD)								# "make build" demands each ~build target, then its own leaf
	@echo [build] $(CURDIR)
	@$(MAKE) --no-print-directory E=1
$(SUBDIRSBUILD): %~build: %							# each ~build target calls "make build" on its subdir
	@$(MAKE) --no-print-directory -C $< build E=0

SUBDIRSCLEAN := $(addsuffix ~clean,$(SUBDIRS))
clean: $(SUBDIRSCLEAN)
	@echo [clean] $(CURDIR)
	@$(MAKE) --no-print-directory clean E=1
$(SUBDIRSCLEAN): %~clean: %
	@$(MAKE) --no-print-directory -C $< clean E=0

# bonus targets for final output
run:
	wiiload $(BUILD)/$(TARGET).dol

.PHONY: build clean run $(SUBDIRS) $(SUBDIRSBUILD) $(SUBDIRSCLEAN)

endif
