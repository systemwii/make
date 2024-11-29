# recursive make
ifeq ($(E),1)						# the E flag ("exec") is set in leaf calls
include $(RULESDIR)/output.mk		# it calls the output (build) script
else								# else, it recurses over subfolders

SUBDIRS := $(dir $(wildcard */*/Makefile */Makefile))

SUBDIRSBUILD := $(addsuffix ~build,$(SUBDIRS))		# virtual targets representing build of subdir
build: $(SUBDIRSBUILD)								# "build" demands each ~build target, then its own leaf
	@$(MAKE) --no-print-directory E=1
$(SUBDIRSBUILD): %~build: %							# each ~build target calls "build" on its subdir
	@$(MAKE) --no-print-directory -C $< build E=0

SUBDIRSCLEAN := $(addsuffix ~clean,$(SUBDIRS))
clean: $(SUBDIRSCLEAN)
	@$(MAKE) --no-print-directory clean E=1
$(SUBDIRSCLEAN): %~clean: %
	@$(MAKE) --no-print-directory -C $< clean E=0

.PHONY: all self clean cleanall $(SUBDIRS) $(SUBDIRSBUILD) $(SUBDIRSCLEAN)

endif
