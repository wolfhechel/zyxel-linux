include $(INCLUDEDIR)/common.mk

export LOADADDR     := 0x94600000
export KERNEL_ENTRY := 0x94100000
export RAMSTART     := 0x94000000
export RAMSIZE      := 0x00100000

export KDIR = $(output)/kernel

SUBDIRS = linux \
		  lzma-loader

all: $(KDIR)/ $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ build

$(KDIR)/:
	mkdir $@

.NOTPARALLEL: $(SUBDIRS)

.PHONY: all $(SUBDIRS)
