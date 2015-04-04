include $(dir $(lastword $(MAKEFILE_LIST)))/../common.mk

static_gcc_configure_options = $(common_gcc_configure) \
                               --with-newlib \
                               --without-headers \
                               --enable-languages=c \
                               --disable-shared \
                               --disable-threads \
                               --disable-decimal-float \
                               --disable-libquadmath \
                               --disable-libatomic \
                               --disable-libitm


$(build)/gcc-static-build/: $(build)/gcc-4.9.2/
	mkdir $@
	cd $@; $</configure $(static_gcc_configure_options)

$(toolchain)/lib/gcc/$(target)/4.9.2/libgcc.a: $(build)/gcc-static-build/
	$(MAKE) -C $< all-gcc all-target-libgcc
	$(MAKE) -C $< install-gcc install-target-libgcc

build: $(toolchain)/lib/gcc/$(target)/4.9.2/libgcc.a
