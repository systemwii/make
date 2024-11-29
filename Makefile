_VERSION := systemwii-0

$(if $(findstring /,$(DEVKITPRO)),,$(error DEVKITPRO not set; run: export DEVKITPRO=<path to>devkitPRO))

all:
	@echo "use dist or install targets"

install:
	@sudo rm -rfv $(DEVKITPRO)/devkitPPC/rules
	@sudo cp -rv rules $(DESTDIR)$(DEVKITPRO)/devkitPPC/rules

dist:
	@tar -cJf devkitppc-rules-$(_VERSION).tar.xz rules Makefile
