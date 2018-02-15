#!/bin/bash
SHDPKG_UBOOTCONFIG='/boot/extlinux/extlinux.conf'
if [ -e $SHDPKG_UBOOTCONFIG ]; then
    echo "Updating ${SHDPKG_UBOOTCONFIG} to boot the newly installed kernel."
    sed -i "s/label .*/label Shedbuilt Linux 4.16rc1/g" $SHDPKG_UBOOTCONFIG
    sed -i "s/kernel .*/kernel \/boot\/linux-4.16rc1-uImage/g" $SHDPKG_UBOOTCONFIG
    sed -i "s/fdt .*/fdt \/boot\/linux-4.16rc1-${SHED_DEVICE}.dtb/g" $SHDPKG_UBOOTCONFIG
fi

