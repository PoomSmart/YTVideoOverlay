ifeq ($(SIMULATOR),1)
	ARCHS = arm64 x86_64
	TARGET = simulator:clang:latest:15.0
else
	ARCHS = arm64
	ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
		TARGET = iphone:clang:latest:15.0
	else
		TARGET = iphone:clang:latest:11.0
	endif
endif
PACKAGE_VERSION = 2.1.1
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTVideoOverlay

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(SIMULATOR),1)
include ../../Simulator/preferenceloader-sim/locatesim.mk
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject/$(TWEAK_NAME).plist
	@mkdir -p $(PL_SIMULATOR_APPLICATION_SUPPORT_PATH)
	@cp -vR $(PWD)/layout/Library/Application\ Support/$(TWEAK_NAME).bundle $(PL_SIMULATOR_APPLICATION_SUPPORT_PATH)/
endif
