.PHONY: all clean
SRC_ARCHIVE = icu4c-52_1-src.tgz
# Sourced from http://site.icu-project.org/download/52#TOC-ICU4C-Download
DATA_ARCHIVE = icudt52l.zip
# Sourced from: http://apps.icu-project.org/datacustom/
# Only contains Miscellaneous Data: rfc3491.spp rfc3920node.spp rfc3920res.spp
DEVELOPER = $(shell xcode-select --print-path)
MACOSX_SDK_VERSION = 10.8
MACOSX_MIN_VERSION = 10.7
IOS_SDK_VERSION = 7.0
IOS_MIN_VERSION = $(IOS_SDK_VERSION)
ICU_FLAGS = MacOSX --enable-static --disable-shared --enable-renaming --enable-extras=no --enable-icuio=no --enable-layout=no --enable-tests=no --enable-samples=no --with-library-suffix=xmppframework
BASE_CFLAGS = -DU_CHARSET_IS_UTF8=1 -DU_USING_ICU_NAMESPACE=0 -DUCONFIG_NO_FILE_IO=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_BREAK_ITERATION=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -DUCONFIG_NO_SERVICE=1 -I$(PWD)/icu/source/common -I$(PWD)/icu/source/tools/tzcode
BASE_CXXFLAGS = -DU_CHARSET_IS_UTF8=1 -DU_USING_ICU_NAMESPACE=0 -DUCONFIG_NO_FILE_IO=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_BREAK_ITERATION=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -DUCONFIG_NO_SERVICE=1 -I$(PWD)/icu/source/common -I$(PWD)/icu/source/tools/tzcode
OUTPUT = lib/libicudataxmppframework.a lib/libicui18nxmppframework.a lib/libicuioxmppframework.a lib/libiculexmppframework.a lib/libiculxxmppframework.a lib/libicutuxmppframework.a lib/libicuucxmppframework.a
CROSS_BUILD_DIR = macosx-x86_64
ICU_TARGET = icu/source/runConfigureICU
ARCH_DIRS = macosx-x86_64 iphonesimulator-i386 iphoneos-armv7s iphoneos-armv7 iphoneos-arm64
ARCH_TARGET = $(patsubst %, %/XMPPStringPrep.a, $(ARCH_DIRS))
UNIVERSAL_TARGET = XMPPStringPrep.a

all: $(UNIVERSAL_TARGET)

XMPPStringPrep.a: $(ARCH_TARGET)
	lipo -create -output $@ $^
	ranlib $@

icu/source/runConfigureICU: $(SRC_ARCHIVE) $(DATA_ARCHIVE)
	rm -fr icu
	tar -zxf $(SRC_ARCHIVE)
	unzip -qod icu/source/data/in $(DATA_ARCHIVE)
	touch $@

macosx-%/XMPPStringPrep.a: ARCH = $(patsubst macosx-%/XMPPStringPrep.a, %, $@)
macosx-%/XMPPStringPrep.a: ARCHFLAGS = -arch $(ARCH)
macosx-%/XMPPStringPrep.a: SDK_NAME = macosx$(MACOSX_SDK_VERSION)
macosx-%/XMPPStringPrep.a: SDK_ROOT = $(DEVELOPER)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$(MACOSX_SDK_VERSION).sdk
macosx-%/XMPPStringPrep.a: CFLAGS = $(BASE_CFLAGS) $(ARCHFLAGS) -mmacosx-version-min=$(MACOSX_MIN_VERSION)
macosx-%/XMPPStringPrep.a: CXXFLAGS = $(BASE_CXXFLAGS) $(ARCHFLAGS) -mmacosx-version-min=$(MACOSX_MIN_VERSION)
macosx-%/XMPPStringPrep.a: LDFLAGS = $(ARCHFLAGS) -mmacosx-version-min=$(MACOSX_MIN_VERSION)
macosx-%/XMPPStringPrep.a: $(ICU_TARGET) XMPPStringPrep.m
	rm -fr $(@D)
	mkdir $(@D)
	cd $(@D) && CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" xcrun -sdk $(SDK_NAME) sh $(PWD)/icu/source/runConfigureICU $(ICU_FLAGS)
	cd $(@D) && gnumake
	cd $(@D) && xcrun -sdk $(SDK_NAME) clang $(CFLAGS) -x objective-c -fobjc-arc -I../icu/source/common -c -o XMPPStringPrep.so ../XMPPStringPrep.m
	cd $(@D) && libtool -static -o XMPPStringPrep.a XMPPStringPrep.so lib/*.a

iphonesimulator-%/XMPPStringPrep.a: ARCH = $(patsubst iphonesimulator-%/XMPPStringPrep.a, %, $@)
iphonesimulator-%/XMPPStringPrep.a: ARCHFLAGS = -arch $(ARCH)
iphonesimulator-%/XMPPStringPrep.a: SDK_NAME = iphonesimulator$(IOS_SDK_VERSION)
iphonesimulator-%/XMPPStringPrep.a: SDK_ROOT = $(DEVELOPER)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator$(IOS_SDK_VERSION).sdk
iphonesimulator-%/XMPPStringPrep.a: CFLAGS = $(BASE_CFLAGS) $(ARCHFLAGS) -isysroot $(SDK_ROOT) -miphoneos-version-min=$(IOS_MIN_VERSION)
iphonesimulator-%/XMPPStringPrep.a: CXXFLAGS = $(BASE_CXXFLAGS) $(ARCHFLAGS) -isysroot $(SDK_ROOT) -miphoneos-version-min=$(IOS_MIN_VERSION)
iphonesimulator-%/XMPPStringPrep.a: LDFLAGS = $(ARCHFLAGS) -miphoneos-version-min=$(IOS_MIN_VERSION)
iphonesimulator-%/XMPPStringPrep.a: $(ICU_TARGET) XMPPStringPrep.m
	rm -fr $(@D)
	mkdir $(@D)
	cd $(@D) && CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" xcrun --sdk $(SDK_NAME) sh $(PWD)/icu/source/runConfigureICU $(ICU_FLAGS)
	cd $(@D) && gnumake
	cd $(@D) && xcrun -sdk $(SDK_NAME) clang $(CFLAGS) -x objective-c -fobjc-arc -I../icu/source/common -c -o XMPPStringPrep.so ../XMPPStringPrep.m
	cd $(@D) && libtool -static -o XMPPStringPrep.a XMPPStringPrep.so lib/*.a

iphoneos-%/XMPPStringPrep.a: ARCH = $(patsubst iphoneos-%/XMPPStringPrep.a, %, $@)
iphoneos-%/XMPPStringPrep.a: ARCHFLAGS = -arch $(ARCH)
iphoneos-%/XMPPStringPrep.a: SDK_NAME = iphoneos$(IOS_SDK_VERSION)
iphoneos-%/XMPPStringPrep.a: SDK_ROOT = $(DEVELOPER)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$(IOS_SDK_VERSION).sdk
iphoneos-%/XMPPStringPrep.a: CFLAGS = $(BASE_CFLAGS) $(ARCHFLAGS) -isysroot $(SDK_ROOT) -miphoneos-version-min=$(IOS_MIN_VERSION)
iphoneos-%/XMPPStringPrep.a: CXXFLAGS = $(BASE_CXXFLAGS) $(ARCHFLAGS) -isysroot $(SDK_ROOT) -miphoneos-version-min=$(IOS_MIN_VERSION)
iphoneos-%/XMPPStringPrep.a: LDFLAGS = $(ARCHFLAGS) -miphoneos-version-min=$(IOS_MIN_VERSION)
iphoneos-%/XMPPStringPrep.a: $(ICU_TARGET) $(CROSS_BUILD_DIR)/XMPPStringPrep.a XMPPStringPrep.m
	rm -fr $(@D)
	mkdir $(@D)
	cd $(@D) && CC="cc $(ARCHFLAGS)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" xcrun --sdk $(SDK_NAME) sh $(PWD)/icu/source/runConfigureICU $(ICU_FLAGS) --host=arm-apple-darwin --with-cross-build=$(PWD)/$(CROSS_BUILD_DIR)
	cd $(@D) && gnumake
	cd $(@D) && xcrun -sdk $(SDK_NAME) clang $(CFLAGS) -x objective-c -fobjc-arc -I../icu/source/common -c -o XMPPStringPrep.so ../XMPPStringPrep.m
	cd $(@D) && libtool -static -o XMPPStringPrep.a XMPPStringPrep.so lib/*.a

clean:
	rm -fr icu $(UNIVERSAL_TARGET) $(ARCH_DIRS)
