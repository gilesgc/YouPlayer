include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = YouPlayer

YouPlayer_FILES = YPRRootListController.m
YouPlayer_INSTALL_PATH = /Library/PreferenceBundles
YouPlayer_FRAMEWORKS = UIKit
YouPlayer_PRIVATE_FRAMEWORKS = Preferences
YouPlayer_CFLAGS = -fobjc-arc
YouPlayer_LIBRARIES = imagepicker colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/YouPlayer.plist$(ECHO_END)
