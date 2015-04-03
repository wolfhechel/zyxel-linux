include $(INCLUDEDIR)/common.mk

linux_src = https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.19.2.tar.xz

build: $(build)/linux-3.19.2/
	$(MAKE) -C $< mrproper
	$(MAKE) ARCH=mips -C $< headers_check
	$(MAKE) ARCH=mips INSTALL_HDR_PATH=$(sysroot) -C $< headers_install
	# For lzma-loader
	cp -v $</arch/mips/include/asm/{asm,regdef,asm-eva}.h $(sysroot)/include/asm/
