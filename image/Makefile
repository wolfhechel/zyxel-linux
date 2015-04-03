include $(INCLUDEDIR)/common.mk

export LOADADDR := 0x94600000
export KERNEL_ENTRY := 0x94100000
export RAMSTART := 0x94000000
export RAMSIZE := 0x00100000

TOOLS = busybox \
		dropbear \
		linux-atm \		#
		libmnl \		# About 31kb
		libnftnl \		# About 150Kb
		nftables		# About 350Kb

SUBDIRS := linux \
		   sangam_atm \
#		   lzma-loader

$(SUBDIRS):
	$(MAKE) -C $@ build

.PHONY: all $(SUBDIRS)
