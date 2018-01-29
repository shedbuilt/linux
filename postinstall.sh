#!/bin/bash
UBOOTCONFIG=/boot/extlinux/extlinux.conf
if [ -e $UBOOTCONFIG ]; then
    echo "Updating ${UBOOTCONFIG} to boot the newly installed kernel."
    sed -i "s/label .*/label Shedbuilt Linux 4.15/g" ${UBOOTCONFIG}
    sed -i "s/kernel .*/kernel \/boot\/linux-4.15-zImage/g" ${UBOOTCONFIG}
    sed -i "s/fdt .*/fdt \/boot\/linux-4.15-${SHED_HWCONFIG}.dtb/g" ${UBOOTCONFIG}
fi
unset UBOOTCONFIG
