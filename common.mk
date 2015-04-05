include $(ROOTDIR)/config.mk

# Source retrieval

define src_url
$($(shell echo "$(1)" | sed "s/^.*\/\(.*\)-.*$$/\1/g")_src)
endef

$(src)/%: $(src)
	@(cd $(dir $@); curl -LO $(call src_url,$@))

$(build)/%/: $(src)/%.tar.*
	@-mkdir $(build)
	tar xvf $(lastword $+) -C $(build)

# Compile options

float_options = --with-float=$(mips_float)

sysroot_options = --prefix=$(toolchain) \
                           --host=$(host) \
                           --build=$(host) \
                           --target=$(target) \
                           --with-sysroot=$(sysroot)



export PATH := $(toolchain)/bin:$(PATH)
