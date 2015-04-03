define src_url
$($(shell echo "$(1)" | sed "s/^.*\/\(.*\)-.*$$/\1/g")_src)
endef

$(src)/%: $(src)
	@(cd $(dir $@); curl -O $(call src_url,$@))

$(build)/%/: $(src)/%.tar.*
	@-mkdir $(build)
	tar xvf $(lastword $+) -C $(build)
