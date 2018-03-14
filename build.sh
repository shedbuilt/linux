#!/bin/bash
case "$SHED_DEVICE" in
    orangepi-one)
        SHDPKG_KERNEL_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-one.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        SHDPKG_KERNEL_COMP='gzip'
        ;;
    orangepi-pc)
        SHDPKG_KERNEL_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-pc.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        SHDPKG_KERNEL_COMP='gzip'
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
SHDPKG_BOOTPATH="arch/${SHDPKG_ARCH}/boot"
SHDPKG_KERNEL_IMG="${SHDPKG_BOOTPATH}/Image"
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config && \
make -j $SHED_NUMJOBS Image dtbs modules && \
INSTALL_MOD_PATH="$SHED_FAKEROOT" make modules_install || exit 1
if [ "$SHDPKG_KERNEL_COMP" == 'gzip' ]; then
    gzip "${SHDPKG_BOOTPATH}/Image" || exit 1
    SHDPKG_KERNEL_IMG="${SHDPKG_BOOTPATH}/Image.gz"
fi
mkimage -A $SHDPKG_KERNEL_ARCH \
        -O linux \
        -C $SHDPKG_KERNEL_COMP \
        -T kernel \
        -d "$SHDPKG_KERNEL_IMG" \
        -a $SHDPKG_KERNEL_LOAD \
        -e $SHDPKG_KERNEL_LOAD \
        -n 'Shedbuilt Linux 4.16rc5'
        "${SHDPKG_BOOTPATH}/uImage" &&
mkdir -v "${SHED_FAKEROOT}/boot" &&
install -m644 System.map "${SHED_FAKEROOT}/boot/System.map-4.16rc5" &&
install -m755 "${SHDPKG_BOOTPATH}/uImage" "${SHED_FAKEROOT}/boot/linux-4.16rc5-uImage" &&
install -m644 "${SHDPKG_BOOTPATH}/dts/${SHDPKG_DTBFILE}" "${SHED_FAKEROOT}/boot/linux-4.16rc5-${SHED_DEVICE}.dtb" &&
install -dm755 "${SHED_FAKEROOT}/usr/share/doc/linux-4.16" &&
cp -r Documentation/* "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
