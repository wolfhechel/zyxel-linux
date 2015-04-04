include $(INCLUDEDIR)/common.mk
musl_src = http://www.musl-libc.org/releases/musl-1.0.4.tar.gz

musl_CFLAGS := -msoft-float -Wa,-msoft-float
musl_CC = $(target)-gcc

musl_configure_options = --prefix=/ \
                         --target=$(target)

$(sysroot)/lib/libc.a: $(build)/musl-1.0.4/
	cd $<; CFLAGS="$(musl_CFLAGS)" CC=$(musl_CC) ./configure $(musl_configure_options)

	$(MAKE) CC=$(musl_CC) CROSS_COMPILE=$(target)- -C $< all
	DESTDIR=$(sysroot) $(MAKE) -C $< install

build: $(sysroot)/lib/libc.a
