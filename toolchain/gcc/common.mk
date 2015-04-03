include $(INCLUDEDIR)/common.mk

gcc_src := ftp://ftp.gnu.org/gnu/gcc/gcc-4.9.2/gcc-4.9.2.tar.bz2

gmp_src := https://gmplib.org/download/gmp/gmp-6.0.0a.tar.bz2
mpfr_src := http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.xz
mpc_src := ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz

musl_gcc_patches = https://github.com/GregorR/musl-gcc-patches.git

define UnpackSupportLibrary
mkdir $(1); curl $(2) | tar xv$(3)f - --strip-components=1 -C $(1)
endef

$(build)/gcc-4.9.2/: $(src)/gcc-4.9.2.tar.*
	tar xvf $< -C $(build)

	cd $@; \
	git clone $(musl_gcc_patches);  \
	for step in $$(cat musl-gcc-patches/series); do  patch -Np1 -i musl-gcc-patches/$$step; done; \
#	$(call UnpackSupportLibrary,gmp,$(gmp_src),j); \
#	$(call UnpackSupportLibrary,mpfr,$(mpfr_src),J); \
#	$(call UnpackSupportLibrary,mpc,$(mpc_src),z)


export libgcc_cv_fixed_point=no


mips_options = --with-endian=$(mips_endian) \
               --with-abi=$(mips_abi) \
               --with-arch=$(mips_arch)


disabled_libraries = --disable-libsanitizer \
                     --disable-libmudflap \
                     --disable-libgomp \
                     --disable-libatomic \
                     --disable-libssp

common_gcc_configure = $(sysroot_options) \
                       --disable-nls \
                       --disable-multilib \
                       $(mips_options) \
                       $(float_options) \
                       $(disabled_libraries)

# make: CFLAGS="-O2 -I/home/vagrant/openwrt/staging_dir/host/include -I/home/vagrant/openwrt/staging_dir/host/usr/include" CFLAGS_FOR_TARGET="-Os -pipe -mno-branch-likely -mips32 -mtune=mips32 -fno-caller-saves -fhonour-copts -Wno-error=unused-but-set-variable -msoft-float" CXXFLAGS_FOR_TARGET="-Os -pipe -mno-branch-likely -mips32 -mtune=mips32 -fno-caller-saves -fhonour-copts -Wno-error=unused-but-set-variable -msoft-float"
2_common_gcc_configure := --prefix=$(toolchain) \
                                        --build=$(host) \
                                        --host=$(host) \
                                        --target=$(target) \
                                        --with-gnu-ld \
                                        --enable-target-optspace \
                                        --disable-libgomp \
                                        --disable-libmudflap \
                                        --disable-multilib \
                                        --disable-libssp \
                                        --disable-nls \
                                        --with-float=soft \
                                        --disable-decimal-float \
                                        --with-mips-plt \
                                        $(mips_options) \

# --with-system-zlib --disable-target-zlib
