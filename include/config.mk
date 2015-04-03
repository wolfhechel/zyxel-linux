output =

host := $(shell echo $$MACHTYPE | sed "s/-[^-]*/-cross/")
target := mips-linux-musl

build = $(output)/build
toolchain = $(output)/toolchain
sysroot = $(toolchain)/$(target)

src := $(ROOTDIR)/src

mips_arch := mips1 # or mips2, mip3, mips4 or mips5
mips_endian := big # or small
mips_float := soft # or hard
mips_abi := 32 # or n32 or 64

include $(ROOTDIR)/config.local

ifeq ($(output),)
$(error output is not set)
endif
