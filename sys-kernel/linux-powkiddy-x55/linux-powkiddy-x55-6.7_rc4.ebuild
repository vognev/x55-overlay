EAPI=8

inherit mount-boot toolchain-funcs

DESCRIPTION="Powkiddy X55 kernel and modules"
HOMEPAGE="https://kernel.org/"

MY_PV=${PV/_rc/-rc}
S="${WORKDIR}/linux-${MY_PV}"
SRC_URI="https://git.kernel.org/torvalds/t/linux-${MY_PV}.tar.gz"
KEYWORDS="-* arm64"

LICENSE="GPL-2"
SLOT="0"
RESTRICT="binchecks strip"

BDEPEND="
	sys-kernel/linux-firmware
	net-wireless/wireless-regdb
	app-arch/cpio
"

src_prepare() {
	cp "${FILESDIR}/${PV}.config" "${S}/.config"

	eapply "${FILESDIR}/${PV}.patch"
	eapply_user

	sed -i '2iexit 0' scripts/depmod.sh
}

src_compile ()
{
	tc-export_build_env
	local makeargs=(
		HOSTCC="$(tc-getBUILD_CC)"
		HOSTCXX="$(tc-getBUILD_CXX)"
		HOSTCFLAGS="${BUILD_CFLAGS}"
		HOSTLDFLAGS="${BUILD_LDFLAGS}"
		CROSS_COMPILE=${CHOST}-
		AS="$(tc-getAS)"
		CC="$(tc-getCC)"
		LD="$(tc-getLD)"
		AR="$(tc-getAR)"
		NM="$(tc-getNM)"
		STRIP="$(tc-getSTRIP)"
		OBJCOPY="$(tc-getOBJCOPY)"
		OBJDUMP="$(tc-getOBJDUMP)"
		ARCH="$(tc-arch-kernel)"
	)

	emake "${makeargs[@]}" olddefconfig
	emake "${makeargs[@]}" Image modules rockchip/rk3566-powkiddy-x55.dtb
}

src_install() {
	local version=$(make kernelrelease)
	local builddir="${ED}/usr/lib/modules/${version}/build"
	
	mkdir -p "${ED}/boot"
	install -Dm644 arch/arm64/boot/Image -T "${ED}/boot/vmlinuz-linux-x55"
	install -Dm644 arch/arm64/boot/dts/rockchip/rk3566-powkiddy-x55.dtb -Dt "${ED}/boot"
	emake INSTALL_MOD_PATH="${ED}/usr" modules_install

	rm -f "${ED}/usr/lib/modules/${version}/"{source,build}
  	rm -r "${ED}/usr/lib/firmware"

  	depmod -b "${ED}/usr" -F System.map "$version"

	# /// 

	install -Dt "$builddir" -m644 .config Module.symvers System.map
}
