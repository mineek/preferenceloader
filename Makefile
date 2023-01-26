TARGET := iphone:clang:14.5:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libprefs
libprefs_FILES = prefs.xm
libprefs_FRAMEWORKS = UIKit
libprefs_LIBRARIES = substrate
libprefs_PRIVATE_FRAMEWORKS = Preferences
libprefs_CFLAGS = -I.
libprefs_COMPATIBILITY_VERSION = 2.2.0
libprefs_LIBRARY_VERSION = $(shell echo "$(THEOS_PACKAGE_BASE_VERSION)" | cut -d'~' -f1)
libprefs_LDFLAGS  = -compatibility_version $($(THEOS_CURRENT_INSTANCE)_COMPATIBILITY_VERSION)
libprefs_LDFLAGS += -current_version $($(THEOS_CURRENT_INSTANCE)_LIBRARY_VERSION)
libprefs_INSTALL_PATH = /var/jb/usr/lib

TWEAK_NAME = PreferenceLoader
PreferenceLoader_FILES = Tweak.xm
PreferenceLoader_FRAMEWORKS = UIKit
PreferenceLoader_PRIVATE_FRAMEWORKS = Preferences
PreferenceLoader_LIBRARIES = prefs
PreferenceLoader_CFLAGS = -I.
PreferenceLoader_LDFLAGS = -L$(THEOS_OBJ_DIR)
PreferenceLoader_INSTALL_PATH = /var/jb/Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-libprefs-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/var/jb/usr/include/libprefs$(ECHO_END)
	$(ECHO_NOTHING)cp prefs.h $(THEOS_STAGING_DIR)/var/jb/usr/include/libprefs/prefs.h$(ECHO_END)

after-stage::
	find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;
	#$(FAKEROOT) chown -R root:admin $(THEOS_STAGING_DIR)
	mkdir -p $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceBundles $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceLoader/Preferences
# 	sudo chown -R root:admin $(THEOS_STAGING_DIR)/Library $(THEOS_STAGING_DIR)/usr

before-package::
	@install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate /var/jb/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate $(THEOS_STAGING_DIR)/var/jb/usr/lib/libprefs.dylib
	@install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate /var/jb/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate $(THEOS_STAGING_DIR)/var/jb/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib
	@install_name_tool -change /usr/lib/libprefs.dylib /var/jb/usr/lib/libprefs.dylib $(THEOS_STAGING_DIR)/var/jb/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib

after-install::
	install.exec "killall -9 Preferences"
