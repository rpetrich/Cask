include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

BUNDLE_NAME = caskprefs
caskprefs_FILES = CaskRootListController.m CaskAppSettingsController.m OrderedDictionary.m
caskprefs_INSTALL_PATH = /Library/PreferenceBundles
caskprefs_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/caskprefs.plist$(ECHO_END)
