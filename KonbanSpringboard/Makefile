ARCHS = arm64 arm64e

SDK_PATH = $(THEOS)/sdks/iPhoneOS13.7.sdk/
SYSROOT = $(SDK_PATH)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KonbanSpringboard
$(TWEAK_NAME)_FILES = KonbanSpringboard.xm Konban.xm
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
# $(TWEAK_NAME)_LIBRARIES = applist
ADDITIONAL_OBJCFLAGS = -fobjc-arc
KonbanSpringboard.xm_CFLAGS += -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk
