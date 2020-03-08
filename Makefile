FINALPACKAGE = 1

export TARGET = iphone:13.0

export ADDITIONAL_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Cask
Cask_FILES = Tweak.x

ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += caskprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
