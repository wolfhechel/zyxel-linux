cmake_minimum_required(VERSION 3.7)

include (ExternalProject)

set (CROSS_COMPILE "" CACHE STRING "Cross compile prefix")

if (CROSS_COMPILE STREQUAL "")
    message (FATAL_ERROR "CROSS_COMPILE not set")
endif (CROSS_COMPILE STREQUAL "")

set (INITRAMFS ${CMAKE_CURRENT_BINARY_DIR}/initramfs)

set (CONFIG_INITRAMFS_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/initramfs.cpio.gz")

configure_file (
    ${CMAKE_CURRENT_SOURCE_DIR}/initramfs/init.sh
    ${CMAKE_CURRENT_BINARY_DIR}/init
)

configure_file (
    ${CMAKE_CURRENT_SOURCE_DIR}/configs/linux-4.1.38.in
    ${CMAKE_CURRENT_BINARY_DIR}/linux-4.1.38.config
    ESCAPE_QUOTES
    @ONLY
)

ExternalProject_Add(
    busybox
    URL http://busybox.net/downloads/busybox-1.26.2.tar.bz2
    URL_HASH SHA1=0b3e3cd49d6d9e30f66e364bf842663348b23dc9
    EXCLUDE_FROM_ALL 1
    BUILD_IN_SOURCE 1
    INSTALL_DIR ${INITRAMFS}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/configs/busybox.config <BINARY_DIR>/.config
    BUILD_COMMAND make ARCH=mips CROSS_COMPILE=${CROSS_COMPILE}
    INSTALL_COMMAND make ARCH=mips CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX=<INSTALL_DIR> install
)

add_custom_command(
    OUTPUT ${INITRAMFS}/init
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/init ${INITRAMFS}/init
    COMMAND chmod +x ${INITRAMFS}/init
)

add_custom_target(
    init
    DEPENDS busybox ${INITRAMFS}/init
)

# Create device nodes

foreach (directory dev proc sys root)
    add_custom_command(
        OUTPUT ${INITRAMFS}/${directory}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${INITRAMFS}/${directory}
    )

    list (APPEND DIRS "${INITRAMFS}/${directory}")
endforeach ()

add_custom_target (
    directories
    DEPENDS ${DIRS}
)

file (READ ${CMAKE_CURRENT_SOURCE_DIR}/initramfs/node-list.txt contents)

STRING(REGEX REPLACE ";" "\\\\;" contents "${contents}")
STRING(REGEX REPLACE "\n" ";" contents "${contents}")

foreach (nod IN LISTS contents)
    string (REGEX MATCH "^([^ ]*)" devname ${nod})

    string(REPLACE " " ";" nod ${nod})
    add_custom_command(
        OUTPUT ${INITRAMFS}/dev/${devname}
        COMMAND fakeroot mknod ${nod}
        WORKING_DIRECTORY ${INITRAMFS}/dev
        DEPENDS ${INITRAMFS}/dev
    )

    list (APPEND DEVICE_NODES ${INITRAMFS}/dev/${devname})
endforeach (nod in LISTS contents)

add_custom_target(
    device-nodes
    DEPENDS ${DEVICE_NODES}
)

add_custom_command(
    OUTPUT ${CONFIG_INITRAMFS_SOURCE}
    COMMAND find . -print0 | cpio --null -ov --format=newc --owner=0:0 | gzip -9 > ${CONFIG_INITRAMFS_SOURCE}
    WORKING_DIRECTORY ${INITRAMFS}
    DEPENDS init busybox device-nodes directories
)

add_custom_target(
    initramfs
    DEPENDS ${CONFIG_INITRAMFS_SOURCE}
)

file (GLOB linux_patches ${CMAKE_CURRENT_SOURCE_DIR}/patches/linux-4.1.38/*.patch)

ExternalProject_Add(
    linux
    URL https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.1.38.tar.xz
    URL_HASH SHA1=58fa94854db192ac1558f96819efff0550f6c09d
    BUILD_IN_SOURCE 1
    DEPENDS initramfs
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/linux-4.1.38.config <BINARY_DIR>/.config
    PATCH_COMMAND cat ${linux_patches} | patch -Np1
    BUILD_COMMAND make ARCH=mips CROSS_COMPILE=${CROSS_COMPILE}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/arch/mips/boot/compressed/vmlinux.bin <INSTALL_DIR>
)