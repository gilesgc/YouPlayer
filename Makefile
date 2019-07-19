INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouPlayer

YouPlayer_FILES = Tweak.xm
YouPlayer_CFLAGS = -fobjc-arc
YouPlayer_LIBRARIES = imagepicker colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += youplayerprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
