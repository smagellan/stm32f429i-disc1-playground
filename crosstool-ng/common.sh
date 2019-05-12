#! /bin/bash

TARGET="arm-none-eabi";
CT_NG_BUILD="$(realpath .build/$TARGET)";
NEWLIB_NANO_HOME="$CT_NG_BUILD/src/newlib";
GCC_HOME="$CT_NG_BUILD/src/gcc";
GCC_SUPP_LIBS="$CT_NG_BUILD/buildtools";


host_arch=`uname -m | sed 'y/XI/xi/'`;
BUILD="$host_arch"-linux-gnu;
HOST_NATIVE="$host_arch"-linux-gnu;
X_TOOLS="$(realpath ~/x-tools/$TARGET)";

NANO_ROOT="$(pwd)/nano-libs";
TMP_INSTALL_PATH="$NANO_ROOT/newlib_nano_install";
