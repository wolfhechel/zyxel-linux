include $(ROOTDIR)/common.mk

src_dir = $(abspath src)

$(build)/lzma-loader/: $(src_dir)/
	cp -Rv $< $@

$(build)/lzma-loader/vmlinux.lzma: $(build)/lzma-loader/ $(KDIR)/vmlinux
	cat $(lastword $+) | lzma e -si -so -eos -lc1 -lp2 -pb2 > $@

$(build)/lzma-loader/lzma.bin: $(build)/lzma-loader/vmlinux.lzma
	$(MAKE) -C $(dir $@) CC="$(target)-gcc" \
			  	CROSS_COMPILE="$(target)-" \
			  	LOADADDR=$(LOADADDR) \
			  	KERNEL_ENTRY=$(KERNEL_ENTRY) \
			  	RAMSTART=$(RAMSTART) \
			  	RAMSIZE=$(RAMSIZE)

$(KDIR)/lzma.bin: $(build)/lzma-loader/lzma.bin
	cp -Rv $< $@

build: $(KDIR)/lzma.bin

.INTERMEDIATE: $(src_dir)/
