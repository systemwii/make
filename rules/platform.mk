PLATFORMMACHINE := $(subst gamecube,ogc,$(subst wii,rvl,$(PLATFORM)))
PLATFORMLIB		:= $(subst gamecube,cube,$(PLATFORM))

PORTLIBS	:=	$(PORTLIBS_PATH)/$(PLATFORM) $(PORTLIBS_PATH)/ppc
export PATH	:=	$(addsuffix /bin,$(PORTLIBS)):$(PATH)
LIBOGC_INC	:=	$(DEVKITPRO)/libogc/include
LIBOGC_LIB	:=	$(DEVKITPRO)/libogc/lib/$(PLATFORMLIB)
MACHDEP		:=  -DGEKKO -m$(PLATFORMMACHINE) -mcpu=750 -meabi -mhard-float
