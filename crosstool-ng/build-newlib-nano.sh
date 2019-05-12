#! /bin/bash


NEWLIB_NANO_HOME="$PWD/../.build/src/newlib-3.1.0.20181231";
GCC_HOME="$PWD/../.build/src/gcc-9.1.0";
GCC_SUPP_LIBS="$PWD/../.build//arm-none-eabi/buildtools";

TMP_INSTALL_PATH="$PWD/newlib_nano_install";

TARGET="arm-none-eabi";
host_arch=`uname -m | sed 'y/XI/xi/'`;
BUILD="$host_arch"-linux-gnu;
HOST_NATIVE="$host_arch"-linux-gnu;
X_TOOLS=`realpath ~/x-tools`;
NANO_ROOT="$PWD";

export CFLAGS_FOR_TARGET='-g -Os -ffunction-sections -fdata-sections';
export PATH=$PATH:$X_TOOLS/$TARGET/bin;


# this routine comes from toolchain-scripts of ARM Holdings
# Copy target libraries from each multilib directories.
# Usage copy_multi_libs dst_prefix=... src_prefix=... target_gcc=...
copy_multi_libs() {
    local -a multilibs
    local multilib
    local multi_dir
    local src_prefix
    local dst_prefix
    local src_dir
    local dst_dir
    local target_gcc

    for arg in "$@" ; do
        eval "${arg// /\\ }"
    done

    multilibs=( $("${target_gcc}" -print-multi-lib 2>/dev/null) )
    for multilib in "${multilibs[@]}" ; do
	echo "about to copy libs for $multilib";
        multi_dir="${multilib%%;*}"
        src_dir=${src_prefix}/${multi_dir}
        dst_dir=${dst_prefix}/${multi_dir}
        cp -v -f "${src_dir}/libstdc++.a" "${dst_dir}/libstdc++_nano.a"
        cp -v -f "${src_dir}/libsupc++.a" "${dst_dir}/libsupc++_nano.a"
        cp -v -f "${src_dir}/libc.a" "${dst_dir}/libc_nano.a"
        cp -v -f "${src_dir}/libg.a" "${dst_dir}/libg_nano.a"
        cp -v -f "${src_dir}/librdimon.a" "${dst_dir}/librdimon_nano.a"
        cp -v -f "${src_dir}/nano.specs" "${dst_dir}/"
        cp -v -f "${src_dir}/rdimon.specs" "${dst_dir}/"
        cp -v -f "${src_dir}/nosys.specs" "${dst_dir}/"
        cp -v -f "${src_dir}/"*crt0.o "${dst_dir}/"
    done
}

rm -rf "$PWD/../.build/$TARGET/build";


echo "building nano newlib..."
mkdir newlib-build; cd newlib-build;


$NEWLIB_NANO_HOME/configure  \
    --build="$BUILD" --host="$HOST_NATIVE" \
    --target=arm-none-eabi \
    --prefix=$TMP_INSTALL_PATH \
    --disable-newlib-supplied-syscalls    \
    --enable-newlib-reent-small           \
    --enable-newlib-retargetable-locking  \
    --disable-newlib-fvwrite-in-streamio  \
    --disable-newlib-fseek-optimization   \
    --disable-newlib-wide-orient          \
    --enable-newlib-nano-malloc           \
    --disable-newlib-unbuf-stream-opt     \
    --enable-lite-exit                    \
    --enable-newlib-global-atexit         \
    --enable-newlib-nano-formatted-io     \
    --disable-nls && make -j9 && make install;


echo "...finished nano newlib build";

cd $NANO_ROOT;
mkdir gcc-build; cd gcc-build;

CXXFLAGS=;

echo "building nano g++ libs..."
$GCC_HOME/configure --target=$TARGET \
    --prefix=$TMP_INSTALL_PATH \
    --enable-languages=c,c++ \
    --disable-decimal-float \
    --disable-libffi \
    --disable-libgomp \
    --disable-libmudflap \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libstdcxx-pch \
    --disable-libstdcxx-verbose \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --disable-tls \
    --with-gnu-as \
    --with-gnu-ld \
    --with-newlib \
    --with-headers=yes \
    --with-python-dir=share/gcc-arm-none-eabi \
    --with-sysroot=$TMP_INSTALL_PATH/arm-none-eabi \
    --build=$BUILD --host=$HOST_NATIVE \
    --with-mpfr="$GCC_SUPP_LIBS" \
    --with-mpc="$GCC_SUPP_LIBS" \
    --with-gmp="$GCC_SUPP_LIBS" \
    "--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm"  \
    "--with-pkgversion=crosstool-NG" \
    --with-multilib-list=rmprofile && make -j9 CXXFLAGS="${CXXFLAGS:-}" CXXFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections -fno-exceptions" && make install;

echo "...finished nano g++ libs build";

cd $NANO_ROOT;

chmod -R u+w $X_TOOLS/$TARGET;
mkdir $X_TOOLS/$TARGET/include/newlib-nano;
cp -v $TMP_INSTALL_PATH/$TARGET/include/newlib.h $X_TOOLS/$TARGET/include/newlib-nano/newlib.h;
copy_multi_libs src_prefix="$TMP_INSTALL_PATH/$TARGET/lib" dst_prefix="$X_TOOLS/$TARGET/$TARGET/lib" target_gcc="$X_TOOLS/$TARGET/bin/$TARGET-gcc";
chmod -R u-w $X_TOOLS/$TARGET;

