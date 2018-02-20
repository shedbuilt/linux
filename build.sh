#!/bin/bash
case "$SHED_DEVICE" in
    orangepi-one)
        SHDPKG_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-one.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        ;;
    orangepi-pc)
        SHDPKG_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-pc.dtb'
        SHDPKG_KERNEL_LOAD='0x40008000'
        ;;
    aml-s905x-cc)
        SHDPKG_ARCH='arm64'
        SHDPKG_DTBFILE='amlogic/meson-gxl-s905x-libretech-cc.dtb'
        SHDPKG_KERNEL_LOAD='0x01080000'
        ;;
    *)
        echo "Unsupported config: $SHED_DEVICE"
        exit 1
        ;;
esac
SHDPKG_BOOTPATH="arch/${SHDPKG_ARCH}/boot"
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config && \
make -j $SHED_NUMJOBS Image dtbs modules && \
INSTALL_MOD_PATH="$SHED_FAKEROOT" make modules_install && \
gzip "${SHDPKG_BOOTPATH}/Image" && \
mkimage -A $SHDPKG_ARCH \
        -O linux \
        -C gzip \
        -T kernel \
        -d "${SHDPKG_BOOTPATH}/Image.gz" \
        -a $SHDPKG_KERNEL_LOAD \
        -e $SHDPKG_KERNEL_LOAD \
        "${SHDPKG_BOOTPATH}/uImage" || exit 1
mkdir -v "${SHED_FAKEROOT}/boot"
install -m644 System.map "${SHED_FAKEROOT}/boot/System.map-4.16rc2"
install -m755 "${SHDPKG_BOOTPATH}/uImage" "${SHED_FAKEROOT}/boot/linux-4.16rc2-uImage"
install -m644 "${SHDPKG_BOOTPATH}/dts/${SHDPKG_DTBFILE}" "${SHED_FAKEROOT}/boot/linux-4.16rc2-${SHED_DEVICE}.dtb"
install -dm755 "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
cp -r Documentation/* "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
