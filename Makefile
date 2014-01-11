.PHONY: all clean osx ios
export CFLAGS CXXFLAGS LDFLAGS

SRC_ARCHIVE = icu4c-52_1-src.tgz
# Source from http://site.icu-project.org/download/52#TOC-ICU4C-Download
DATA_ARCHIVE = icudt52l.zip
# Source from: http://apps.icu-project.org/datacustom/
# Select Miscellaneous Data: rfc3491.spp rfc3920node.spp rfc3920res.spp

OSX_SDK_VERSION = 10.9
OSX_MIN_VERSION = 10.9
OSX_ARCH = MacOSX-x86_64
OSX_TARGET = $(patsubst %,build/%/XMPPStringPrep.a,$(OSX_ARCH))
IOS_SDK_VERSION = 7.0
IOS_MIN_VERSION = 7.0
IOS_ARCH = iPhoneSimulator-i386 iPhoneSimulator-x86_64 iPhoneOS-armv7 iPhoneOS-armv7s iPhoneOS-arm64
IOS_TARGET = $(patsubst %,build/%/XMPPStringPrep.a,$(IOS_ARCH))
ALL_TARGET = XMPPStringPrep-osx.a XMPPStringPrep-ios.a
CROSS_TARGET_DIR = build/MacOSX-x86_64/icu
CROSS_TARGET = $(CROSS_TARGET_DIR)/libicuxmppframework.a
NEEDS_CROSS_TARGET = $(patsubst %/XMPPStringPrep.a,%/icu/libicuxmppframework.a,$(IOS_TARGET))
XCODEDIR = $(shell xcode-select -p)

BASE_ICU_FLAGS = MacOSX --enable-static --disable-shared --enable-renaming  --enable-extras=no --enable-icuio=no --enable-layout=no --enable-tests=no --enable-samples=no --with-library-suffix=xmppframework
BASE_CFLAGS = -DU_CHARSET_IS_UTF8=1 -DU_USING_ICU_NAMESPACE=0 -DUCONFIG_NO_FILE_IO=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_BREAK_ITERATION=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -DUCONFIG_NO_SERVICE=1
BASE_CXXFLAGS = -DU_CHARSET_IS_UTF8=1 -DU_USING_ICU_NAMESPACE=0 -DUCONFIG_NO_FILE_IO=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_BREAK_ITERATION=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -DUCONFIG_NO_SERVICE=1

all: $(ALL_TARGET)
osx: XMPPStringPrep-osx.a
ios: XMPPStringPrep-ios.a

XMPPStringPrep-osx.a: $(OSX_TARGET)
XMPPStringPrep-ios.a: $(IOS_TARGET)
XMPPStringPrep-%.a:
	lipo -create -output $@ $^

$(NEEDS_CROSS_TARGET): $(CROSS_TARGET)

build/%: OS_ARCH = $(word 2,$(subst /, ,$@))
build/%: OS = $(firstword $(subst -, ,$(OS_ARCH)))
build/%: ARCH = $(word 2,$(subst -, ,$(OS_ARCH)))
build/%: BASEDIR = $(XCODEDIR)/Platforms/$(OS).platform/Developer
build/%: PATH = $(BASEDIR)/usr/bin:$(BASEDIR)/usr/sbin:$(shell echo $$PATH)
build/MacOSX-%: SDK = $(BASEDIR)/SDKs/MacOSX$(OSX_SDK_VERSION).sdk
build/MacOSX-%: CFLAGS = -mmacosx-version-min=$(OSX_MIN_VERSION)  -arch $(ARCH) -isysroot $(SDK) $(BASE_CFLAGS)
build/MacOSX-%: CXXFLAGS = -mmacosx-version-min=$(OSX_MIN_VERSION)  -arch $(ARCH) -isysroot $(SDK) $(BASE_CXXFLAGS)
build/MacOSX-%: LDFLAGS = -mmacosx-version-min=$(OSX_MIN_VERSION)  -arch $(ARCH) -isysroot $(SDK) $(BASE_LDFLAGS)
build/MacOSX-%: ICU_FLAGS = $(BASE_ICU_FLAGS)
build/iPhoneSimulator-%: SDK = $(BASEDIR)/SDKs/iPhoneSimulator$(IOS_SDK_VERSION).sdk
build/iPhoneSimulator-%: ICU_FLAGS = $(BASE_ICU_FLAGS) --with-cross-build=$(PWD)/$(CROSS_TARGET_DIR)/build
build/iPhoneOS-%: SDK = $(BASEDIR)/SDKs/iPhoneOS$(IOS_SDK_VERSION).sdk
build/iPhoneOS-%: ICU_FLAGS = $(BASE_ICU_FLAGS) --host=arm-apple-darwin --with-cross-build=$(PWD)/$(CROSS_TARGET_DIR)/build
build/iPhone%: CFLAGS = -miphoneos-version-min=$(IOS_MIN_VERSION) -arch $(ARCH) -isysroot $(SDK) $(BASE_CFLAGS)
build/iPhone%: CXXFLAGS = -miphoneos-version-min=$(IOS_MIN_VERSION) -arch $(ARCH) -isysroot $(SDK) $(BASE_CXXFLAGS)
build/iPhone%: LDFLAGS = -miphoneos-version-min=$(IOS_MIN_VERSION) -arch $(ARCH) -isysroot $(SDK) $(BASE_LDFLAGS)

build/%/icu/libicuxmppframework.a: $(SRC_ARCHIVE) $(DATA_ARCHIVE)
	rm -fr $(@D)
	mkdir -p $(@D)/src $(@D)/build
	tar -C $(@D)/src -zxf $(SRC_ARCHIVE)
	unzip -qod $(@D)/src/icu/source/data/in $(DATA_ARCHIVE)
	cd $(@D)/build && ../src/icu/source/runConfigureICU $(ICU_FLAGS) && $(MAKE)
	libtool -static -o $@ $(@D)/build/lib/libicudataxmppframework.a $(@D)/build/lib/libicui18nxmppframework.a $(@D)/build/lib/libicutuxmppframework.a $(@D)/build/lib/libicuucxmppframework.a

build/%/XMPPStringPrep.a: build/%/icu/libicuxmppframework.a XMPPStringPrep.m
	clang $(CFLAGS) -x objective-c -fobjc-arc -I $(@D)/icu/src/icu/source/common -c -o $(@D)/XMPPStringPrep.so XMPPStringPrep.m
	libtool -static -o $@ $(@D)/XMPPStringPrep.so $(@D)/icu/libicuxmppframework.a

clean:
	rm -fr build *.a
