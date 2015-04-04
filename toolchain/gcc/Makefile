include $(dir $(lastword $(MAKEFILE_LIST)))/common.mk

gcc_configure_options = $(common_gcc_configure) \
                        --enable-languages=c \
                        --enable-c99 \
                        --enable-long-long

$(build)/gcc-build/: $(build)/gcc-4.9.2/
	mkdir $@
	cd $@; $</configure $(gcc_configure_options)

$(toolchain)/bin/$(target)-gcc: $(build)/gcc-build/
	$(MAKE) -C $< all
	$(MAKE) -C $< install

build: $(toolchain)/bin/$(target)-gcc
