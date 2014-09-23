include theos/makefiles/common.mk

BUNDLE_NAME = libPreferenceProtect
libPreferenceProtect_FILES = AES.m libPreferenceProtect.mm
libPreferenceProtect_INSTALL_PATH = /Library/PreferenceBundles
libPreferenceProtect_FRAMEWORKS = UIKit
libPreferenceProtect_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/libPreferenceProtect.plist$(ECHO_END)
