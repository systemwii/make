_VERSION := s2.0

$(if $(findstring /,$(DEVKITPRO)),,$(error DEVKITPRO not set; run: export DEVKITPRO=<path to>devkitPRO))

# skip if invoked externally/recursively by make / make build / make clean
build clean:
	@exit

install:
	@sudo rm -rfv $(DEVKITPRO)/devkitPPC/rules
	@sudo cp -rv rules $(DESTDIR)$(DEVKITPRO)/devkitPPC/rules

dist:
	@tar -cJf devkitppc-rules-$(_VERSION).tar.xz rules Makefile
