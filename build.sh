#!/bin/bash
case "$SHED_DEVICE" in
    all-h3-cc)
        SHDPKG_KERNEL_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-libretech-all-h3-cc.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        SHDPKG_KERNEL_COMP='gzip'
        ;;
    orangepi-one)
        SHDPKG_KERNEL_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-one.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        SHDPKG_KERNEL_COMP='gzip'
        ;;
    orangepi-lite)
        SHDPKG_KERNEL_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-lite.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        SHDPKG_KERNEL_COMP='gzip'
        ;;
    orangepi-pc)
        SHDPKG_KERNEL_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-pc.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        SHDPKG_KERNEL_COMP='gzip'
        ;;
    orangepi-pc2)
	SHDPKG_KERNEL_ARCH='arm64'
        SHDPKG_DTBFILE='allwinner/sun50i-h5-orangepi-pc2.dtb'
        SHDPKG_KERNEL_LOAD='0x40080000'
        SHDPKG_KERNEL_COMP='none'
	;;
    aml-s905x-cc)
        SHDPKG_KERNEL_ARCH='arm64'
        SHDPKG_DTBFILE='amlogic/meson-gxl-s905x-libretech-cc.dtb'
        SHDPKG_KERNEL_LOAD='0x01080000'
        SHDPKG_KERNEL_COMP='none'
        ;;
    *)
        echo "Unsupported config: $SHED_DEVICE"
        exit 1
        ;;
esac
SHDPKG_BOOTPATH="arch/${SHDPKG_KERNEL_ARCH}/boot"
SHDPKG_KERNEL_IMG="${SHDPKG_BOOTPATH}/Image"
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config && \
make -j $SHED_NUMJOBS Image dtbs modules && \
INSTALL_MOD_PATH="$SHED_FAKEROOT" make modules_install || exit 1
if [ "$SHDPKG_KERNEL_COMP" == 'gzip' ]; then
    gzip "$SHDPKG_KERNEL_IMG" || exit 1
    SHDPKG_KERNEL_IMG="${SHDPKG_BOOTPATH}/Image.gz"
fi
mkimage -A $SHDPKG_KERNEL_ARCH \
        -O linux \
        -C $SHDPKG_KERNEL_COMP \
        -T kernel \
        -d "$SHDPKG_KERNEL_IMG" \
        -a $SHDPKG_KERNEL_LOAD \
        -e $SHDPKG_KERNEL_LOAD \
        -n 'Shedbuilt Linux 4.16' \
        "${SHDPKG_BOOTPATH}/uImage" &&
mkdir -v "${SHED_FAKEROOT}/boot" &&
install -m644 System.map "${SHED_FAKEROOT}/boot/System.map-4.16" &&
install -m755 "${SHDPKG_BOOTPATH}/uImage" "${SHED_FAKEROOT}/boot/linux-4.16-uImage" &&
install -m644 "${SHDPKG_BOOTPATH}/dts/${SHDPKG_DTBFILE}" "${SHED_FAKEROOT}/boot/linux-4.16.dtb" &&
install -dm755 "${SHED_FAKEROOT}/usr/share/doc/linux-4.16" &&
cp -r Documentation/* "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
