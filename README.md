# XMPPStringPrep-ICU

__License: BSD__

An [ICU](http://icu-project.org) backed drop-in replacement for the [Libidn](http://www.gnu.org/software/libidn/) backed `XMPPStringPrep` class supplied with [XMPPFramework](https://github.com/robbiehanson/XMPPFramework).

## Build steps

* Download [icu4c-52_1-src.tgz](http://site.icu-project.org/download/52#TOC-ICU4C-Download)
* Download [icudt52l.zip](http://apps.icu-project.org/datacustom/) -- select `rfc3491.spp`, `rfc3920node.spp` and `rfc3920res.spp` from “Miscellaneous Data” for a minimal library
* Build with one of the following. Add the jobs flag to speed up the build (eg: `make -j 5`).
    * `make osx` to produce `XMPPStringPrep-osx.a` for OS X (x86_64)
    * `make ios` to produce `XMPPStringPrep-ios.a` for iOS (arm64, armv7, armv7s, i386 and x86_64)
    * `make all` for both

## Usage

* Remove XMPPFramework's `XMPPStringPrep.m` from your projects build phases
* Link your project against `libstdc++.dylib` and the appropriate `.a`
