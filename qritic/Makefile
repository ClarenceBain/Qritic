ARCHS = arm64e
TARGET = iphone:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME=rootless
THEOS_PACKAGE_INSTALL_PREFIX=/var/jb


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Qritic
Qritic_FILES = Tweak.xm
Qritic_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk
