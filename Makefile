export ROOTDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export INCLUDEDIR = $(ROOTDIR)

SUBDIRS := toolchain image

include $(INCLUDEDIR)/common.mk

all: $(build) $(src) $(SUBDIRS)

$(build) $(src):
	-mkdir $@

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	rm -rf $(build)

.NOTPARALLEL: $(SUBDIRS)
.PHONY: all $(SUBDIRS)
