include theos/makefiles/common.mk
TWEAK_NAME = Cask
Cask_FILES = Tweak.x
Cask_FRAMEWORKS = UIKit CoreGraphics

OPTFLAG = -Os

IPHONE_ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0

include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
	install.exec "killall -9 SpringBoard"