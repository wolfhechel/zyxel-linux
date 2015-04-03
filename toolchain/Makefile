include $(INCLUDEDIR)/common.mk

SUBDIRS = binutils \
		  gcc/static \
		  linux-headers \
		  musl \
		  gcc

all: $(sysroot) $(SUBDIRS)

$(sysroot):
	mkdir -pv $@
	ln -sfv . $@/usr

$(SUBDIRS):
	$(MAKE) -C $@ build

.NOTPARALLEL: $(SUBDIRS)

.PHONY: all $(SUBDIRS)
