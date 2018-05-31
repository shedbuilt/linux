#!/bin/bash
SHED_PKG_LOCAL_UBOOT_CONFIG='/boot/extlinux/extlinux.conf'
if [ -e $SHED_PKG_LOCAL_UBOOT_CONFIG ]; then
    echo "Updating ${SHED_PKG_LOCAL_UBOOT_CONFIG} to boot the newly installed kernel."
    sed -i "s/label .*/label Shedbuilt Linux ${SHED_PKG_VERSION}/g" $SHED_PKG_LOCAL_UBOOT_CONFIG
    sed -i "s/kernel .*/kernel \/boot\/linux-${SHED_PKG_VERSION}-${SHED_DEVICE}-uImage/g" $SHED_PKG_LOCAL_UBOOT_CONFIG
    sed -i "s/fdt .*/fdt \/boot\/linux-${SHED_PKG_VERSION}-${SHED_DEVICE}.dtb/g" $SHED_PKG_LOCAL_UBOOT_CONFIG
fi
