include $(INCLUDEDIR)/common.mk

SUBDIRS = lzma

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ build

.NOTPARALLEL: $(SUBDIRS)

.PHONY: all $(SUBDIRS)
