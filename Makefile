export ROOTDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SUBDIRS := tools toolchain image

include $(ROOTDIR)/common.mk

all: $(build) $(src) $(SUBDIRS)

$(build) $(src):
	-mkdir $@

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	rm -rf $(build)

.NOTPARALLEL: $(SUBDIRS)
.PHONY: all $(SUBDIRS)
