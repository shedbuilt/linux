#!/bin/bash
case "$SHED_DEVICE" in
    orangepi-one)
        SHDPKG_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-one.dtb'
        ;;
    orangepi-pc)
        SHDPKG_ARCH='arm'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-pc.dtb'
        ;;
    aml-s905x-cc)
        SHDPKG_ARCH='arm64'
        SHDPKG_DTBFILE='amlogic/meson-gxl-s905x-libretech-cc.dtb'
        ;;
    *)
        echo "Unsupported config: $SHED_DEVICE"
        exit 1
        ;;
esac
SHDPKG_BOOTPATH="arch/${SHDPKG_ARCH}/boot"
make mrproper && \
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config && \
make -j $SHED_NUMJOBS Image dtbs modules && \
INSTALL_MOD_PATH="$SHED_FAKEROOT" make modules_install && \
gzip "${SHDPKG_BOOTPATH}/Image" && \
mkimage -A $SHDPKG_ARCH -O linux -C gzip -T kernel -d "${SHDPKG_BOOTPATH}/Image.gz" "${SHDPKG_BOOTPATH}/uImage" || exit 1
mkdir -v "${SHED_FAKEROOT}/boot"
install -m644 System.map "${SHED_FAKEROOT}/boot/System.map-4.16rc1"
install -m755 "${SHDPKG_BOOTPATH}/uImage" "${SHED_FAKEROOT}/boot/linux-4.16rc1-uImage"
install -m644 "${SHDPKG_BOOTPATH}/dts/${DTBFILE}" "${SHED_FAKEROOT}/boot/linux-4.16rc1-${SHED_DEVICE}.dtb"
install -dm755 "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
cp -r Documentation/* "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
