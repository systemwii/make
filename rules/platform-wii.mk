include $(DEVKITPPC)/recipes.mk

PORTLIBS	:=	$(PORTLIBS_PATH)/wii $(PORTLIBS_PATH)/ppc
export PATH :=  $(PORTLIBS_PATH)/wii/bin:$(PORTLIBS_PATH)/ppc/bin:$(PATH)

export	LIBOGC_INC	:=	$(DEVKITPRO)/libogc/include
export	LIBOGC_LIB	:=	$(DEVKITPRO)/libogc/lib/wii

MACHDEP =  -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float
