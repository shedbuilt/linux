#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
SHED_PKG_LOCAL_KERNEL_CONFIG=''
for $SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    # Configure
    case "$SHED_PKG_LOCAL_OPTION" in
        all-h3-cc)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm'
            SHED_PKG_LOCAL_DTBFILE='sun8i-h3-libretech-all-h3-cc.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
            SHED_PKG_LOCAL_KERNEL_COMP='gzip'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i'
            ;;
        orangepi-one)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm'
            SHED_PKG_LOCAL_DTBFILE='sun8i-h3-orangepi-one.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
            SHED_PKG_LOCAL_KERNEL_COMP='gzip'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i'
            ;;
        orangepi-lite)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm'
            SHED_PKG_LOCAL_DTBFILE='sun8i-h3-orangepi-lite.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
            SHED_PKG_LOCAL_KERNEL_COMP='gzip'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i'
            ;;
        orangepi-pc)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm'
            SHED_PKG_LOCAL_DTBFILE='sun8i-h3-orangepi-pc.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
            SHED_PKG_LOCAL_KERNEL_COMP='gzip'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i'
            ;;
        orangepi-pc2)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm64'
            SHED_PKG_LOCAL_DTBFILE='allwinner/sun50i-h5-orangepi-pc2.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40080000'
            SHED_PKG_LOCAL_KERNEL_COMP='none'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun50i'
	        ;;
        nanopi-m1-plus)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm'
            SHED_PKG_LOCAL_DTBFILE='sun8i-h3-nanopi-m1-plus.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
            SHED_PKG_LOCAL_KERNEL_COMP='gzip'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i'
            patch -Np1 -i "${SHED_PKG_PATCH_DIR}/4.17-nanopi-m1-plus-dts.patch" || exit 1
            ;;
        nanopi-neo)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm'
            SHED_PKG_LOCAL_DTBFILE='sun8i-h3-nanopi-neo.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
            SHED_PKG_LOCAL_KERNEL_COMP='gzip'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i-headless'
            patch -Np1 -i "${SHED_PKG_PATCH_DIR}/4.16-nanopi-neo-dts.patch" || exit 1
            ;;
        nanopi-neo2)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm64'
            SHED_PKG_LOCAL_DTBFILE='allwinner/sun50i-h5-nanopi-neo2.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40080000'
            SHED_PKG_LOCAL_KERNEL_COMP='none'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun50i-headless'
            patch -Np1 -i "${SHED_PKG_PATCH_DIR}/4.16-nanopi-neo2-dts.patch" || exit 1
    	    ;;
        nanopi-neo-plus2)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm64'
            SHED_PKG_LOCAL_DTBFILE='allwinner/sun50i-h5-nanopi-neo-plus2.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x40080000'
            SHED_PKG_LOCAL_KERNEL_COMP='none'
            SHED_PKG_LOCAL_KERNEL_CONFIG='sun50i-headless'
            patch -Np1 -i "${SHED_PKG_PATCH_DIR}/4.16-nanopi-neo-plus2-dts.patch" || exit 1
    	    ;;
        aml-s905x-cc)
            SHED_PKG_LOCAL_KERNEL_ARCH='arm64'
            SHED_PKG_LOCAL_DTBFILE='amlogic/meson-gxl-s905x-libretech-cc.dtb'
            SHED_PKG_LOCAL_KERNEL_LOAD='0x01080000'
            SHED_PKG_LOCAL_KERNEL_COMP='none'
            SHED_PKG_LOCAL_KERNEL_CONFIG='aml-s905x-cc'
            ;;
    esac
done
SHED_PKG_LOCAL_BOOTPATH="arch/${SHED_PKG_LOCAL_KERNEL_ARCH}/boot"
SHED_PKG_LOCAL_KERNEL_IMG="${SHED_PKG_LOCAL_BOOTPATH}/Image"
cp "${SHED_PKG_CONTRIB_DIR}/${SHED_PKG_LOCAL_KERNEL_CONFIG}.config" .config &&
# Build and Install
make -j $SHED_NUM_JOBS Image dtbs modules &&
INSTALL_MOD_PATH="$SHED_FAKE_ROOT" make modules_install || exit 1
if [ "$SHED_PKG_LOCAL_KERNEL_COMP" == 'gzip' ]; then
    gzip "$SHED_PKG_LOCAL_KERNEL_IMG" || exit 1
    SHED_PKG_LOCAL_KERNEL_IMG="${SHED_PKG_LOCAL_BOOTPATH}/Image.gz"
fi
# Wrap and optionally compress kernel image for u-boot
mkimage -A $SHED_PKG_LOCAL_KERNEL_ARCH \
        -O linux \
        -C $SHED_PKG_LOCAL_KERNEL_COMP \
        -T kernel \
        -d "$SHED_PKG_LOCAL_KERNEL_IMG" \
        -a $SHED_PKG_LOCAL_KERNEL_LOAD \
        -e $SHED_PKG_LOCAL_KERNEL_LOAD \
        -n "Linux ${SHED_PKG_VERSION}" \
        "${SHED_PKG_LOCAL_BOOTPATH}/uImage" &&
mkdir -v "${SHED_FAKE_ROOT}/boot" &&
install -m644 System.map "${SHED_FAKE_ROOT}/boot/System-${SHED_PKG_VERSION}.map" &&
install -m755 "${SHED_PKG_LOCAL_BOOTPATH}/uImage" "${SHED_FAKE_ROOT}/boot/linux-${SHED_PKG_VERSION}-uImage" &&
install -m644 "${SHED_PKG_LOCAL_BOOTPATH}/dts/${SHED_PKG_LOCAL_DTBFILE}" "${SHED_FAKE_ROOT}/boot/linux-${SHED_PKG_VERSION}.dtb" || exit 1
# Install Documentation
if [ -n "${SHED_PKG_LOCAL_OPTIONS[docs]}" ]; then
    install -dm755 "${SHED_FAKE_ROOT}${SHED_PKG_DOC_INSTALL_DIR}" &&
    cp -r Documentation/* "${SHED_FAKE_ROOT}${SHED_PKG_DOC_INSTALL_DIR}" || exit 1
fi
