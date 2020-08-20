include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

_THEOS_TARGET_SWIFT_LDPATH = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/swift/iphoneos -L/usr/lib/swift -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/swift-5.0/iphoneos/ -rpath /usr/lib/swift

BUNDLE_NAME = caskprefs
caskprefs_FILES = CaskRootListController.m CaskAppSettingsController.m OrderedDictionary.swift CaskTwitterCell.swift
caskprefs_INSTALL_PATH = /Library/PreferenceBundles
caskprefs_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices
caskprefs_SWIFT_BRIDGING_HEADER = caskprefs-Bridging-Header.h

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/caskprefs.plist$(ECHO_END)
