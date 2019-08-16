#! /bin/bash

source common.sh;

cd $NANO_ROOT || exit 1;

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


echo "building nano newlib..."
mkdir -p newlib-build && cd newlib-build;
export CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections -fdebug-prefix-map=$NEWLIB_NANO_HOME=$(realpath $X_TOOLS/usr/src/newlib)";


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
unset CFLAGS_FOR_TARGET;
echo "...finished nano newlib build";



cd $NANO_ROOT;

echo "building nano g++ libs..."
mkdir -p gcc-build && cd gcc-build;

CXXFLAGS=;


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
    --with-multilib-list=rmprofile && \
    make -j9 CXXFLAGS="${CXXFLAGS:-}" CXXFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections -fno-exceptions -fdebug-prefix-map=$GCC_HOME=$(realpath $X_TOOLS/usr/src/gcc)" \
    CCFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections -fno-exceptions -fdebug-prefix-map=$GCC_HOME=$(realpath $X_TOOLS/usr/src/gcc)" \
    && make install;


echo "...finished nano g++ libs build";

cd $NANO_ROOT;


mkdir $X_TOOLS/include/newlib-nano;
cp -v $TMP_INSTALL_PATH/$TARGET/include/newlib.h $X_TOOLS/include/newlib-nano/newlib.h;
copy_multi_libs src_prefix="$TMP_INSTALL_PATH/$TARGET/lib" dst_prefix="$X_TOOLS/$TARGET/lib" target_gcc="$X_TOOLS/bin/$TARGET-gcc";


cd $GCC_HOME && find libstdc++-v3/ -regextype egrep -iregex '.*\.(c|cpp|cc|h|hpp)' | cpio -pdm "$X_TOOLS/usr/src/gcc";
cd $NEWLIB_NANO_HOME && find newlib/libc -regextype egrep -iregex '.*\.(c|cpp|cc|h|hpp)' | cpio -pdm "$X_TOOLS/usr/src/newlib";
