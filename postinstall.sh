#!/bin/bash
SHED_PKG_LOCAL_UBOOT_CONFIG='/boot/extlinux/extlinux.conf'
SHED_PKG_LOCAL_DTB_FILE=''
declare -a SHED_PKG_LOCAL_OPTIONS=( ${SHED_OPTIONS} )
for SHED_PKG_LOCAL_OPTION in "${SHED_PKG_LOCAL_OPTIONS[@]}"; do
    case "$SHED_PKG_LOCAL_OPTION" in
        allh3cc)
            SHED_PKG_LOCAL_DTB_FILE='sun8i-h3-libretech-all-h3-cc.dtb'
            ;;
        orangepione)
            SHED_PKG_LOCAL_DTB_FILE='sun8i-h3-orangepi-one.dtb'
            ;;
        orangepilite)
            SHED_PKG_LOCAL_DTB_FILE='sun8i-h3-orangepi-lite.dtb'
            ;;
        orangepipc)
            SHED_PKG_LOCAL_DTB_FILE='sun8i-h3-orangepi-pc.dtb'
            ;;
        orangepipc2)
            SHED_PKG_LOCAL_DTB_FILE='sun50i-h5-orangepi-pc2.dtb'
	        ;;
        nanopim1plus)
            SHED_PKG_LOCAL_DTB_FILE='sun8i-h3-nanopi-m1-plus.dtb'
            ;;
        nanopineo)
            SHED_PKG_LOCAL_DTB_FILE='sun8i-h3-nanopi-neo.dtb'
            ;;
        nanopineo2)
            SHED_PKG_LOCAL_DTB_FILE='sun50i-h5-nanopi-neo2.dtb'
    	    ;;
        nanopineoplus2)
            SHED_PKG_LOCAL_DTB_FILE='sun50i-h5-nanopi-neo-plus2.dtb'
    	    ;;
    esac
done
if [ -z "$SHED_PKG_LOCAL_DTB_FILE" ]; then
    echo "Aborting update to ${SHED_PKG_LOCAL_UBOOT_CONFIG} as a compatible DTB file cannot be found."
    exit 1
fi
if [ -e "$SHED_PKG_LOCAL_UBOOT_CONFIG" ]; then
    sed -i "s/label .*/label Shedbuilt Linux ${SHED_PKG_VERSION}/g" $SHED_PKG_LOCAL_UBOOT_CONFIG &&
    sed -i "s/kernel .*/kernel \/boot\/linux-${SHED_PKG_VERSION}-uImage/g" $SHED_PKG_LOCAL_UBOOT_CONFIG &&
    sed -i "s/fdt .*/fdt \/boot\/dtb\/${SHED_PKG_LOCAL_DTB_FILE}/g" $SHED_PKG_LOCAL_UBOOT_CONFIG &&
    echo "Updated ${SHED_PKG_LOCAL_UBOOT_CONFIG} to boot the newly installed kernel."
fi
