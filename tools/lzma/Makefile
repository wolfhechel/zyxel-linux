include $(INCLUDEDIR)/common.mk

lzma_src = http://downloads.sourceforge.net/project/sevenzip/LZMA%20SDK/4.65/lzma465.tar.bz2

$(src)/lzma465.tar.bz2: $(src)
	@(cd $(dir $@); curl -LO $(lzma_src))

$(build)/lzma-4.65/: $(src)/lzma465.tar.bz2
	mkdir -p $@
	tar xvf $(lastword $+) -C $@

$(build)/lzma-4.65/CPP/7zip/Compress/LZMA_Alone/lzma: $(build)/lzma-4.65/
	$(MAKE) -C $(dir $@) -f makefile.gcc

$(toolchain)/bin/lzma: $(build)/lzma-4.65/CPP/7zip/Compress/LZMA_Alone/lzma
	mkdir -p $(dir $@)
	cp $< $@

build: $(toolchain)/bin/lzma
