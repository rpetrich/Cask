ifeq ($(shell [ -f ./framework/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	git submodule update --init
	./framework/git-submodule-recur.sh init
	$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else

TWEAK_NAME = Cask
Cask_FILES = Tweak.x
Cask_FRAMEWORKS = UIKit CoreGraphics

OPTFLAG = -Os

IPHONE_ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk

endif
