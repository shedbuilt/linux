#!/bin/bash
SHDPKG_UBOOTCONFIG='/boot/extlinux/extlinux.conf'
if [ -e $SHDPKG_UBOOTCONFIG ]; then
    echo "Updating ${SHDPKG_UBOOTCONFIG} to boot the newly installed kernel."
    sed -i "s/label .*/label Shedbuilt Linux 4.16.1/g" $SHDPKG_UBOOTCONFIG
    sed -i "s/kernel .*/kernel \/boot\/linux-4.16.1-uImage/g" $SHDPKG_UBOOTCONFIG
    sed -i "s/fdt .*/fdt \/boot\/linux-4.16.1.dtb/g" $SHDPKG_UBOOTCONFIG
fi

