include $(INCLUDEDIR)/common.mk

kernel_dir = $(build)/linux-3.19.2/


src_dir = $(abspath $(dir $(lastword $(MAKEFILES_LIST))))/src

$(src_dir)/vmlinux.lzma: $(kernel_dir)/vmlinux
	cat $< | lzma e -si -so -eos -lc1 -lp2 -pb2 > $@

$(src_dir)/loader.elf: $(src_dir)/vmlinux.lzma
	$(MAKE) -C $(src_dir) CC="$(TARGET_CC)" \
						  CROSS_COMPILE="$(TARGET_CROSS)" \
						  KDIR=$(kernel_dir) \
						  LOADADDR=$(LOADADDR) \
						  KERNEL_ENTRY=$(KERNEL_ENTRY) \
						  RAMSTART=$(RAMSTART) \
						  RAMSIZE=$(RAMSIZE)

#
