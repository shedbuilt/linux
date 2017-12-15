#!/bin/bash
make mrproper
cp ${SHED_CONTRIBDIR}/${SHED_HWCONFIG}.config .config
make -j $SHED_NUMJOBS zImage dtbs modules
INSTALL_MOD_PATH=${SHED_FAKEROOT} make modules_install
mkdir -v ${SHED_FAKEROOT}/boot
install -m644 ${SHED_SRCDIR}System.map ${SHED_FAKEROOT}/boot/System.map-4.15rc3
install -m755 ${SHED_SRCDIR}/arch/arm/boot/zImage ${SHED_FAKEROOT}/boot/linux-4.15rc3-zImage
DTBFILE=${SHED_SRCDIR}/arch/arm/boot/dts/
if [ ${SHED_HWCONFIG} == "orangepi-one" ]; then
    DTBFILE+=sun8i-h3-orangepi-one.dtb
fi
install -m644 ${DTBFILE} ${SHED_FAKEROOT}/boot/linux-4.15rc3-${SHED_HWCONFIG}.dtb
install -d ${SHED_FAKEROOT}/usr/share/doc/linux-4.15
cp -r Documentation/* ${SHED_FAKEROOT}/usr/share/doc/linux-4.15
