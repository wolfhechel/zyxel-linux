include $(INCLUDEDIR)/config.mk
include $(INCLUDEDIR)/sources.mk

float_options = --with-float=$(mips_float)

sysroot_options = --prefix=$(toolchain) \
                           --host=$(host) \
                           --build=$(host) \
                           --target=$(target) \
                           --with-sysroot=$(sysroot)


export PATH := $(toolchain)/bin:$(PATH)
