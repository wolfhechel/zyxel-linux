include $(INCLUDEDIR)/common.mk

binutils_src = http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2

binutils_configure_options = $(sysroot_options) \
			         		 $(float_options) \
			         		 --enable-plugins \
			         		 --disable-nls \
			         		 --disable-multilib \
			         		 --disable-werror \
			         		 --disable-libssp

$(build)/binutils-build/: $(build)/binutils-2.25/
	mkdir $@
	cd $@; $</configure $(binutils_configure_options)

build: $(build)/binutils-build/
	$(MAKE) -C $< all
	$(MAKE) -C $< install
