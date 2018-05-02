#!/bin/bash
SHED_PKG_SHOULD_INSTALL_DOCS=false
for SHED_PKG_OPTION in ${SHED_PKG_OPTIONS[@]}; do
    if [ "$SHED_PKG_OPTION" == 'docs' ]; then
        SHED_PKG_SHOULD_INSTALL_DOCS=true
    fi
done
case "$SHED_DEVICE" in
    all-h3-cc)
        SHED_PKG_KERNEL_ARCH='arm'
        SHED_PKG_DTBFILE='sun8i-h3-libretech-all-h3-cc.dtb'
        SHED_PKG_KERNEL_LOAD='0x40008000'
        SHED_PKG_KERNEL_COMP='gzip'
        ;;
    orangepi-one)
        SHED_PKG_KERNEL_ARCH='arm'
        SHED_PKG_DTBFILE='sun8i-h3-orangepi-one.dtb'
        SHED_PKG_KERNEL_LOAD='0x40008000'
        SHED_PKG_KERNEL_COMP='gzip'
        ;;
    orangepi-lite)
        SHED_PKG_KERNEL_ARCH='arm'
        SHED_PKG_DTBFILE='sun8i-h3-orangepi-lite.dtb'
        SHED_PKG_KERNEL_LOAD='0x40008000'
        SHED_PKG_KERNEL_COMP='gzip'
        ;;
    orangepi-pc)
        SHED_PKG_KERNEL_ARCH='arm'
        SHED_PKG_DTBFILE='sun8i-h3-orangepi-pc.dtb'
        SHED_PKG_KERNEL_LOAD='0x40008000'
        SHED_PKG_KERNEL_COMP='gzip'
        ;;
    orangepi-pc2)
        SHED_PKG_KERNEL_ARCH='arm64'
        SHED_PKG_DTBFILE='allwinner/sun50i-h5-orangepi-pc2.dtb'
        SHED_PKG_KERNEL_LOAD='0x40080000'
        SHED_PKG_KERNEL_COMP='none'
	    ;;
    nanopi-m1-plus)
        SHED_PKG_KERNEL_ARCH='arm'
        SHED_PKG_DTBFILE='sun8i-h3-nanopi-m1-plus.dtb'
        SHED_PKG_KERNEL_LOAD='0x40008000'
        SHED_PKG_KERNEL_COMP='gzip'
        patch -Np1 -i "${SHED_PATCHDIR}/4.17-nanopi-m1-plus-dts.patch" || exit 1
        ;;
    nanopi-neo)
        SHED_PKG_KERNEL_ARCH='arm'
        SHED_PKG_DTBFILE='sun8i-h3-nanopi-neo.dtb'
        SHED_PKG_KERNEL_LOAD='0x40008000'
        SHED_PKG_KERNEL_COMP='gzip'
        patch -Np1 -i "${SHED_PATCHDIR}/4.16-nanopi-neo-dts.patch" || exit 1
        ;;
    nanopi-neo2)
        SHED_PKG_KERNEL_ARCH='arm64'
        SHED_PKG_DTBFILE='allwinner/sun50i-h5-nanopi-neo2.dtb'
        SHED_PKG_KERNEL_LOAD='0x40080000'
        SHED_PKG_KERNEL_COMP='none'
        patch -Np1 -i "${SHED_PATCHDIR}/4.16-nanopi-neo2-dts.patch" || exit 1
    	;;
    nanopi-neo-plus2)
        SHED_PKG_KERNEL_ARCH='arm64'
        SHED_PKG_DTBFILE='allwinner/sun50i-h5-nanopi-neo-plus2.dtb'
        SHED_PKG_KERNEL_LOAD='0x40080000'
        SHED_PKG_KERNEL_COMP='none'
        patch -Np1 -i "${SHED_PATCHDIR}/4.16-nanopi-neo-plus2-dts.patch" || exit 1
    	;;
    aml-s905x-cc)
        SHED_PKG_KERNEL_ARCH='arm64'
        SHED_PKG_DTBFILE='amlogic/meson-gxl-s905x-libretech-cc.dtb'
        SHED_PKG_KERNEL_LOAD='0x01080000'
        SHED_PKG_KERNEL_COMP='none'
        ;;
    *)
        echo "Unsupported config: $SHED_DEVICE"
        exit 1
        ;;
esac
SHED_PKG_BOOTPATH="arch/${SHED_PKG_KERNEL_ARCH}/boot"
SHED_PKG_KERNEL_IMG="${SHED_PKG_BOOTPATH}/Image"
cp "${SHED_PKG_CONTRIB_DIR}/${SHED_DEVICE}.config" .config &&
make -j $SHED_NUM_JOBS Image dtbs modules &&
INSTALL_MOD_PATH="$SHED_FAKE_ROOT" make modules_install || exit 1
if [ "$SHED_PKG_KERNEL_COMP" == 'gzip' ]; then
    gzip "$SHED_PKG_KERNEL_IMG" || exit 1
    SHED_PKG_KERNEL_IMG="${SHED_PKG_BOOTPATH}/Image.gz"
fi
mkimage -A $SHED_PKG_KERNEL_ARCH \
        -O linux \
        -C $SHED_PKG_KERNEL_COMP \
        -T kernel \
        -d "$SHED_PKG_KERNEL_IMG" \
        -a $SHED_PKG_KERNEL_LOAD \
        -e $SHED_PKG_KERNEL_LOAD \
        -n "Shedbuilt Linux ${SHED_PKG_VERSION}" \
        "${SHED_PKG_BOOTPATH}/uImage" &&
mkdir -v "${SHED_FAKE_ROOT}/boot" &&
install -m644 System.map "${SHED_FAKE_ROOT}/boot/System-${SHED_PKG_VERSION}.map" &&
install -m755 "${SHED_PKG_BOOTPATH}/uImage" "${SHED_FAKE_ROOT}/boot/linux-${SHED_PKG_VERSION}-${SHED_DEVICE}-uImage" &&
install -m644 "${SHED_PKG_BOOTPATH}/dts/${SHED_PKG_DTBFILE}" "${SHED_FAKE_ROOT}/boot/linux-${SHED_PKG_VERSION}-${SHED_DEVICE}.dtb" || exit 1
if $SHED_PKG_SHOULD_INSTALL_DOCS; then
    install -dm755 "${SHED_FAKE_ROOT}/usr/share/doc/linux-${SHED_PKG_VERSION}" &&
    cp -r Documentation/* "${SHED_FAKE_ROOT}/usr/share/doc/linux-${SHED_PKG_VERSION}" || exit 1
fi
