include $(ROOTDIR)/common.mk

export LOADADDR     := 0x94020000
export KERNEL_ENTRY := $(LOADADDR) # 0x9419f560
export RAMSTART     := 0x94008000
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
