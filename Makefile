ARCHS = arm64 armv7

include theos/makefiles/common.mk

TWEAK_NAME = libPreferenceProtect
libPreferenceProtect_FILES = Tweak.xm PPPreferenceProtect.m
libPreferenceProtect_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
