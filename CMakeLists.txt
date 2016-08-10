cmake_minimum_required (VERSION 2.8.11)
project (ZyNIX)

include(ExternalProject)

set (CROSS_TRIPLET mips-unknown-linux-uclibc)
set (CROSS_COMPILE /home/vagrant/x-tools/${CROSS_TRIPLET}/bin/${CROSS_TRIPLET}-)

set (ARCH mips)

set (SOURCE_CACHE ${PROJECT_BINARY_DIR}/sources)

file (MAKE_DIRECTORY ${SOURCE_CACHE})

file (
    COPY ${PROJECT_SOURCE_DIR}/initramfs/initramfs.txt
    DESTINATION ${PROJECT_BINARY_DIR}
)

file (APPEND ${PROJECT_BINARY_DIR}/initramfs.txt "file /bin/busybox ${PROJECT_BINARY_DIR}/bin/busybox 0755 0 0\n")
file (APPEND ${PROJECT_BINARY_DIR}/initramfs.txt "file /init ${PROJECT_SOURCE_DIR}/initramfs/init.sh 0755 0 0\n")


ExternalProject_Add(
    BusyBox
    URL http://busybox.net/downloads/busybox-1.24.2.tar.bz2
    URL_HASH SHA1=03e6cfc8ddb2f709f308719a9b9f4818bc0a28d0
    DOWNLOAD_DIR ${SOURCE_CACHE}
    BUILD_IN_SOURCE 1
    INSTALL_DIR ${PROJECT_BINARY_DIR}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/configs/busybox.config <BINARY_DIR>/.config
    BUILD_COMMAND make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH}
    INSTALL_COMMAND make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} CONFIG_PREFIX=<INSTALL_DIR> install
)


ExternalProject_Add(
    Linux
    DEPENDS BusyBox
    URL https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.1.11.tar.xz
    URL_HASH SHA1=28bd4fbdef18c35adeaa82179045154e33829a79
    DOWNLOAD_DIR ${SOURCE_CACHE}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND bash -c "cat ${PROJECT_SOURCE_DIR}/patches/linux/*.patch | patch -Np1"
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/configs/linux.config <BINARY_DIR>/.config
    BUILD_COMMAND make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/arch/${ARCH}/boot/compressed/vmlinux.bin <INSTALL_DIR>/
)


ExternalProject_Add_Step(
    Linux
    Create_initramfs
    COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/initramfs.txt <BINARY_DIR>/initramfs.txt
    COMMENT "Copy initramfs.txt"
    DEPENDEES configure
    DEPENDERS build
)


#ExternalProject_Add(
#    sangam-atm
#    URL https://downloads.openwrt.org/sources/sangam_atm-D7.05.01.00-R1.tar.bz2
#)