THEOS_DEVICE_IP = 192.168.1.208

FINALPACKAGE = 1

export TARGET = iphone:13.5:12.0

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc -O3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Cask
Cask_FILES = Tweak.x Cask.swift

_THEOS_TARGET_SWIFT_LDPATH = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/swift/iphoneos -L/usr/lib/swift -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/swift-5.0/iphoneos/ -rpath /usr/lib/swift

ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"
SUBPROJECTS += caskprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
