include $(DEVKITPPC)/recipes.mk

PORTLIBS	:=	$(PORTLIBS_PATH)/gamecube $(PORTLIBS_PATH)/ppc
export PATH	:=	$(PORTLIBS_PATH)/gamecube/bin:$(PORTLIBS_PATH)/ppc/bin:$(PATH)

export	LIBOGC_INC	:=	$(DEVKITPRO)/libogc/include
export	LIBOGC_LIB	:=	$(DEVKITPRO)/libogc/lib/cube

MACHDEP =  -DGEKKO -mogc -mcpu=750 -meabi -mhard-float
