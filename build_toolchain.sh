#!/bin/sh

set -o errexit
set -o nounset
set -o errtrace

linux_version=4.10.1
gcc_version=6.3.0
binutils_version=2.27
gmp_version=6.1.2
mpc_version=1.0.3
mpfr_version=3.1.5
isl_version=0.18
musl_version=1.1.16
https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.bz2
https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.bz2
ftp://ftp.gnu.org/gnu/mpc/mpc-${mpc_version}.tar.gz
https://gmplib.org/download/gmp/gmp-${gmp_version}.tar.bz2
http://www.mpfr.org/mpfr-current/mpfr-${mpfr_version}.tar.xz
http://isl.gforge.inria.fr/isl-${isl_version}.tar.xz
https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz

TOPDIR=${PWD}
TOOLCHAIN=${TOPDIR}/toolchain
SYSROOT=${TOOLCHAIN}/sysroot
BUILD_DIR=${TOPDIR}/build
DL_DIR=${TOPDIR}/sources

TARGET_ARCH=mips
TARGET_VENDOR=unknown
TARGET_OS=linux
TARGET_LIBC=musl

TARGET_TRIPLET="${TARGET_ARCH}-${TARGET_VENDOR}-${TARGET_OS}-${TARGET_LIBC}"

MAKEFLAGS="-j$(nproc)"

# Download sources
mkdir -p ${DL_DIR}
(
    cd ${DL_DIR}

    wget -nc -c -i - << EOF
https://cdn.kernel.org/pub/linux/kernel/v${linux_version%%.*}.x/linux-$linux_version.tar.xz4.10.1
https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.bz2
https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.bz2
ftp://ftp.gnu.org/gnu/mpc/mpc-${mpc_version}.tar.gz
https://gmplib.org/download/gmp/gmp-${gmp_version}.tar.bz2
http://www.mpfr.org/mpfr-current/mpfr-${mpfr_version}.tar.xz
http://isl.gforge.inria.fr/isl-${isl_version}.tar.xz
https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz
EOF
)

# Extract sources
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

for archive in ${DL_DIR}/*.tar.*; do
    tar xvf ${archive}
done

# Prepare directories

mkdir -pv ${SYSROOT}
ln -sv . ${SYSROOT}/usr

# Build Linux headers
(
    cd linux-${linux_version}

    make mrproper

    make ARCH=${TARGET_ARCH} headers_check
    make ARCH=${TARGET_ARCH} INSTALL_HDR_PATH=${SYSROOT}/usr headers_install
)


# Prepare combined GCC source tree
mkdir gcc-bundle
(
    cd gcc-bundle

    ln -sv ../gcc-${gcc_version}/* .
    ln -sv ../binutils-${binutils_version}/{bfd,binutils,gas,gprof,gold,ld,opcodes} .
    ln -sv ../mpc-${mpc_version} mpc
    ln -sv ../gmp-${gmp_version} gmp
    ln -sv ../mpfr-${mpfr_version} mpfr
    ln -sv ../isl-${isl_version} isl
)

# Configure GCC source tree
mkdir gcc-build
(
    cd gcc-build

    ../gcc-bundle/configure \
        --target=${TARGET_TRIPLET} \
        --prefix= \
        --libdir=/lib \
        --with-sysroot=/sysroot \
        --with-build-sysroot=${SYSROOT} \
        --with-arch=mips32 \
        --with-float=soft \
        --with-endian=big \
        --enable-languages=c,c++ \
        --enable-tls \
        --enable-libstdcxx-time \
        --disable-libquadmath \
        --disable-decimal-float \
        --disable-werror \
        --disable-nls \
        --disable-multilib \
        --disable-libmudflap \
        --disable-libsanitizer \
        --disable-gnu-indirect-function \
        --disable-libmpx
)

# Build bootstrap GCC
(
    cd gcc-build
    make all-gcc
)

# Configure musl and install libc headers
mkdir musl-build
(
    cd musl-build

    ../musl-${musl_version}/configure \
        --prefix=/usr \
        --host=${TARGET_TRIPLET} \
        --enable-optimize \
        CC="../gcc-build/gcc/xgcc -B ../gcc-build/gcc" \
        LIBCC="../gcc-build/${TARGET_TRIPLET}/libgcc/libgcc.a"

    make -j2 DESTDIR=${SYSROOT} install-headers
)

# Build static libgcc
(
    cd gcc-build

    make configure-target-libgcc
    make -C ${TARGET_TRIPLET}/libgcc libgcc.a
)

# Build and install musl libc
(
    cd musl-build

    make CROSS_COMPILE=../gcc-build/binutils/
    make DESTDIR=${SYSROOT} install
)

# Finish building and installing GCC toolchain
(
    cd gcc-build

    make

    make DESTDIR=${TOOLCHAIN} install
)