#!/bin/bash
make mrproper
cp ${SHED_CONTRIBDIR}/${SHED_HWCONFIG}.config .config || exit 1
make -j $SHED_NUMJOBS zImage dtbs modules || exit 1
INSTALL_MOD_PATH=${SHED_FAKEROOT} make modules_install || exit 1
mkdir -v ${SHED_FAKEROOT}/boot
install -m644 ${SHED_SRCDIR}System.map ${SHED_FAKEROOT}/boot/System.map-4.15rc5
install -m755 ${SHED_SRCDIR}/arch/arm/boot/zImage ${SHED_FAKEROOT}/boot/linux-4.15rc5-zImage
DTBFILE=${SHED_SRCDIR}/arch/arm/boot/dts/
case "$SHED_HWCONFIG" in
    orangepi-one)
        DTBFILE+=sun8i-h3-orangepi-one.dtb
        ;;
    orangepi-pc)
        DTBFILE+=sun8i-h3-orangepi-pc.dtb
        ;;
    *)
        echo "Unsupported config: $SHED_HWCONFIG"
        exit 1
        ;;
esac
install -m644 ${DTBFILE} ${SHED_FAKEROOT}/boot/linux-4.15rc5-${SHED_HWCONFIG}.dtb
install -d ${SHED_FAKEROOT}/usr/share/doc/linux-4.15
cp -r Documentation/* ${SHED_FAKEROOT}/usr/share/doc/linux-4.15
