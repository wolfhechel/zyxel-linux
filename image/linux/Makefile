include $(INCLUDEDIR)/common.mk

kernel_dir = $(build)/linux-3.19.2

#CFLAGS := -D__KERNEL__ -Wall -Wstrict-prototypes -Wno-trigraphs -Os \
#	-fno-strict-aliasing -fno-common -fomit-frame-pointer -G 0 -mno-abicalls -fno-pic \
#	-pipe -mlong-calls -fno-common \
#	-mabi=32 -march=mips32 -Wa,-32 -Wa,-march=mips32 -Wa,-mips32 -Wa,--trap \
#	-DLOADADDR=$(LOADADDR)

config_file = $(abspath ./config)

$(kernel_dir)/initramdisk/: $(kernel_dir)/
	-mkdir $@

$(kernel_dir)/initramdisk/init: $(kernel_dir)/initramdisk/
	echo "void main() { for (;;) {} }" | $(target)-gcc -xc -static -Wa,-msoft-float - -o $@

$(kernel_dir)/vmlinux: $(kernel_dir)/initramdisk/init
	make -C $(kernel_dir) mrproper
	cp $(config_file) $(kernel_dir)/.config
	make ARCH=mips CROSS_COMPILE=$(target)- -C $(kernel_dir)

build: $(kernel_dir)/vmlinux
