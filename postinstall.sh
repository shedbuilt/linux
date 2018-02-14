#!/bin/bash
case "$SHED_DEVICE" in
    orangepi-one|orangepi-pc)
        SHDPKG_IMGTYPE='zImage'
        ;;
    aml-s905x-cc)
        SHDPKG_IMGTYPE='uImage'
        ;;
    *)
        echo "Unsupported config: $SHED_DEVICE"
        exit 1
        ;;
esac
SHDPKG_UBOOTCONFIG='/boot/extlinux/extlinux.conf'
if [ -e $SHDPKG_UBOOTCONFIG ]; then
    echo "Updating ${SHDPKG_UBOOTCONFIG} to boot the newly installed kernel."
    sed -i "s/label .*/label Shedbuilt Linux 4.16rc1/g" $SHDPKG_UBOOTCONFIG
    sed -i "s/kernel .*/kernel \/boot\/linux-4.16rc1-${SHDPKG_IMGTYPE}/g" $SHDPKG_UBOOTCONFIG
    sed -i "s/fdt .*/fdt \/boot\/linux-4.16rc1-${SHED_DEVICE}.dtb/g" $SHDPKG_UBOOTCONFIG
fi

