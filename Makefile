export TARGET = iphone:latest:15.0
export THEOS_DEVICE_IP = localhost
export THEOS_DEVICE_PORT=2222

export DEBUG = 0
export FINALPACKAGE = 1
export THEOS_PACKAGE_SCHEME=rootless
include $(THEOS)/makefiles/common.mk

SUBPROJECTS += KonbanSpringboard KonbanClient KonbanPrefs

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"