ARCHS = arm64 arm64e

SDK_PATH = $(THEOS)/sdks/iPhoneOS15.6.sdk/
SYSROOT = $(SDK_PATH)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KonbanSpringboard
$(TWEAK_NAME)_FILES = KonbanSpringboard.xm Konban.xm
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
ADDITIONAL_OBJCFLAGS = -fobjc-arc
KonbanSpringboard.xm_CFLAGS += -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk
