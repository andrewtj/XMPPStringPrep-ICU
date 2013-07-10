# XMPPStringPrep-ICU

__License: BSD__

An [ICU](http://icu-project.org) backed drop-in replacement for the [Libidn](http://www.gnu.org/software/libidn/) backed `XMPPStringPrep` class supplied with [XMPPFramework](https://github.com/robbiehanson/XMPPFramework).

## Build steps

* Download [icu4c-51_2-src.tgz](http://site.icu-project.org/download/51#TOC-ICU4C-Download)
* Download [icudt51l.zip](http://apps.icu-project.org/datacustom/) - select `rfc3491.spp`, `rfc3920node.spp` and `rfc3920res.spp` from “Miscellaneous Data” for a minimal library
* `make -j 4`

## Usage

* Remove `XMPPStringPrep.m` from your projects build phases (if present)
* Link your project against `libstdc++.dylib` and `XMPPStringPrep.a`
