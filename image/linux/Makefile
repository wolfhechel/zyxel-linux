include $(ROOTDIR)/common.mk

kernel_dir = $(build)/linux-3.19.2

CFLAGS := -D__KERNEL__ -Wall -Wstrict-prototypes -Wno-trigraphs -Os \
	-fno-strict-aliasing -fno-common -fomit-frame-pointer -G 0 -mno-abicalls -fno-pic \
	-pipe -mlong-calls -fno-common \
	-mabi=32 -march=mips32 -Wa,-32 -Wa,-march=mips32 -Wa,-mips32 -Wa,--trap \
	-DLOADADDR=$(LOADADDR)


REMOVE_SECTIONS = .reginfo .notes .note .comment .mdebug .note.gnu.build-id
OBJCOPY_FLAGS = -O binary $(addprefix -R,$(REMOVE_SECTIONS))

OBJCOPY = $(target)-objcopy $(OBJCOPY_FLAGS) -S

#DROP_SECTIONS:=.reginfo .mdebug .comment .note .pdr .options .MIPS.options
#OBJCOPY_SREC:=$(TARGET_CROSS)objcopy -S -O srec $(addprefix --remove-section=,$(DROP_SECTIONS))

config_file = $(abspath ./config)

$(kernel_dir)/initramdisk/: $(kernel_dir)/
	-mkdir $@

$(kernel_dir)/vmlinux: $(kernel_dir)/initramdisk/
	make -C $(kernel_dir) mrproper
	cp $(config_file) $(kernel_dir)/.config
	make ARCH=mips CROSS_COMPILE=$(target)- EXTRA_CFLAGS="-UVMLINUX_LOAD_ADDRESS -DVMLINUX_LOAD_ADDRESS=$(LOADADDR)" -C $(kernel_dir)

$(KDIR)/vmlinux: $(kernel_dir)/vmlinux
	$(OBJCOPY) $< $@

build: $(KDIR)/vmlinux
