#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
declare -a SHED_PKG_LOCAL_DTBS
# Patch
for SHED_PKG_LOCAL_PATCH in "${SHED_PKG_PATCH_DIR}"/*; do
     patch -Np1 -i "$SHED_PKG_LOCAL_PATCH" || exit 1
done
# Configure
if [ -n "${SHED_PKG_LOCAL_OPTIONS[sun8i]}" ]; then
    SHED_PKG_LOCAL_KERNEL_ARCH='arm'
    SHED_PKG_LOCAL_KERNEL_LOAD='0x40008000'
    SHED_PKG_LOCAL_KERNEL_COMP='gzip'
    SHED_PKG_LOCAL_KERNEL_CONFIG='sun8i'
    SHED_PKG_LOCAL_DTBS=( 'sun8i-h3-libretech-all-h3-cc.dtb' 'sun8i-h3-orangepi-one.dtb' 'sun8i-h3-orangepi-lite.dtb' 'sun8i-h3-orangepi-pc.dtb' 'sun8i-h3-nanopi-m1-plus.dtb' 'sun8i-h3-nanopi-neo.dtb')
elif [ -n "${SHED_PKG_LOCAL_OPTIONS[sun50i]}" ]; then
    SHED_PKG_LOCAL_KERNEL_ARCH='arm64'
    SHED_PKG_LOCAL_KERNEL_LOAD='0x40080000'
    SHED_PKG_LOCAL_KERNEL_COMP='none'
    SHED_PKG_LOCAL_KERNEL_CONFIG='sun50i'
    SHED_PKG_LOCAL_DTBS=( 'allwinner/sun50i-h5-orangepi-pc2.dtb' 'allwinner/sun50i-h5-nanopi-neo2.dtb' 'allwinner/sun50i-h5-nanopi-neo-plus2.dtb')
fi
if [ -n "${SHED_PKG_LOCAL_OPTIONS[headless]}" ]; then
    SHED_PKG_LOCAL_KERNEL_CONFIG="${SHED_PKG_LOCAL_KERNEL_CONFIG}-headless"
fi
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
install -dm755 "${SHED_FAKE_ROOT}/boot/dtb" &&
install -m644 System.map "${SHED_FAKE_ROOT}/boot/System-${SHED_PKG_VERSION}.map" &&
install -m755 "${SHED_PKG_LOCAL_BOOTPATH}/uImage" "${SHED_FAKE_ROOT}/boot/linux-${SHED_PKG_VERSION}-uImage" || exit 1
# Install Device Tree binaries
for SHED_PKG_LOCAL_DTBFILE in "${SHED_PKG_LOCAL_DTBS[@]}"; do
    install -m644 "${SHED_PKG_LOCAL_BOOTPATH}/dts/${SHED_PKG_LOCAL_DTBFILE}" "${SHED_FAKE_ROOT}/boot/dtb" || exit 1
done
# Install Documentation
if [ -n "${SHED_PKG_LOCAL_OPTIONS[docs]}" ]; then
    install -dm755 "${SHED_FAKE_ROOT}${SHED_PKG_DOCS_INSTALL_DIR}" &&
    cp -r Documentation/* "${SHED_FAKE_ROOT}${SHED_PKG_DOCS_INSTALL_DIR}" || exit 1
fi
