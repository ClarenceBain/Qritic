ARCHS = arm64e
export TARGET = iphone:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
export THEOS_PACKAGE_SCHEME=rootless


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Qritic

Qritic_FILES = Tweak.xm
Qritic_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
