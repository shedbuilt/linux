#!/bin/bash
make mrproper && \
cp "${SHED_CONTRIBDIR}/${SHED_HWCONFIG}.config" .config && \
make -j $SHED_NUMJOBS zImage dtbs modules && \
INSTALL_MOD_PATH="$SHED_FAKEROOT" make modules_install || exit 1
mkdir -v "${SHED_FAKEROOT}/boot"
install -m644 System.map "${SHED_FAKEROOT}/boot/System.map-4.16rc1"
install -m755 arch/arm/boot/zImage "${SHED_FAKEROOT}/boot/linux-4.16rc1-zImage"
DTBFILE='arch/arm/boot/dts/'
case "$SHED_HWCONFIG" in
    orangepi-one)
        DTBFILE+='sun8i-h3-orangepi-one.dtb'
        ;;
    orangepi-pc)
        DTBFILE+='sun8i-h3-orangepi-pc.dtb'
        ;;
    *)
        echo "Unsupported config: $SHED_HWCONFIG"
        exit 1
        ;;
esac
install -m644 "${DTBFILE}" "${SHED_FAKEROOT}/boot/linux-4.16rc1-${SHED_HWCONFIG}.dtb"
install -dm755 "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
cp -r Documentation/* "${SHED_FAKEROOT}/usr/share/doc/linux-4.16"
