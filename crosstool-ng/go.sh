#! /bin/bash

source common.sh;


rm -rf $CT_NG_BUILD/build;
rm -rf $NANO_ROOT/newlib-build;
rm -rf $NANO_ROOT/gcc-build;

#ct-ng build || exit 1;


export PATH=$PATH:$X_TOOLS/bin;
rm -rf $CT_NG_BUILD/build;


mkdir -p $X_TOOLS/usr/src/newlib;
mkdir -p $X_TOOLS/usr/src/gcc;
mkdir -p $NANO_ROOT && ./build-nano-libs.sh;