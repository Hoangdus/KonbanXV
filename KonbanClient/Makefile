ARCHS = arm64 arm64e

SDK_PATH = $(THEOS)/sdks/iPhoneOS15.6.sdk/
SYSROOT = $(SDK_PATH)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KonbanClient
$(TWEAK_NAME)_FILES = KonbanClient.xm
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
ADDITIONAL_OBJCFLAGS = -fobjc-arc
KonbanClient.xm_CFLAGS += -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk
