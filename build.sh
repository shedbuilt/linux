#!/bin/bash
case "$SHED_DEVICE" in
    orangepi-one)
        SHDPKG_BOOTPATH='arch/arm/boot'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-one.dtb'
        SHDPKG_IMGTYPE='zImage'
        ;;
    orangepi-pc)
        SHDPKG_BOOTPATH='arch/arm/boot'
        SHDPKG_DTBFILE='sun8i-h3-orangepi-pc.dtb'
        SHDPKG_IMGTYPE='zImage'
        ;;
    aml-s905x-cc)
        SHDPKG_BOOTPATH='arch/arm64/boot'
        SHDPKG_DTBFILE='meson-gxl-s905x-libretech-cc.dtb'
        SHDPKG_IMGTYPE='uImage'
        ;;
    *)
        echo "Unsupported config: $SHED_DEVICE"
        exit 1
        ;;
esac
make mrproper && \
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config && \
make -j $SHED_NUMJOBS $SHDPKG_IMGTYPE dtbs modules && \
INSTALL_MOD_PATH="$SHED_FAKEROOT" make modules_install || exit 1
mkdir -v "${SHED_FAKEROOT}/boot"
install -m644 System.map "${SHED_FAKEROOT}/boot/System.map-4.16rc1"
install -m755 "${SHDPKG_BOOTPATH}/${SHDPKG_IMGTYPE}" "${SHED_FAKEROOT}/boot/linux-4.16rc1-${SHDPKG_IMGTYPE}"
install -m644 "${DTBFILE}" "${SHED_FAKEROOT}/boot/linux-4.16rc1-${SHED_DEVICE}.dtb"
install -dm755 "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
cp -r Documentation/* "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
