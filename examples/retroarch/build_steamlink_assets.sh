#!/bin/bash
#

TOP=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
if [ "${MARVELL_SDK_PATH}" = "" ]; then
	MARVELL_SDK_PATH="$(cd "${TOP}/../.." && pwd)"
fi
if [ "${MARVELL_ROOTFS}" = "" ]; then
	source "${MARVELL_SDK_PATH}/setenv.sh" || exit 1
fi
BUILD="${PWD}"
SRC="${PWD}/retroarch-assets"

# Extra environment variables for this build
export OS=Linux
export CC="${CROSS}gcc"
export CPP="${CROSS}cpp"
export CXX="${CROSS}g++"
export CFLAGS="--sysroot=$MARVELL_ROOTFS -DLINUX=1 -DEGL_API_FB=1 -marm"
export LDFLAGS="--sysroot=$MARVELL_ROOTFS -static-libgcc -static-libstdc++ -lEGL"
export INCLUDE_DIRS="-I$MARVELL_ROOTFS/usr/include -I$MARVELL_ROOTFS/usr/include/EGL -I$MARVELL_ROOTFS/usr/include/SDL2 -I${MARVELL_ROOTFS}/include/GLES2 -I$MARVELL_ROOTFS/usr/include/freetype2"
export LIBRARY_DIRS="-L$MARVELL_ROOTFS/usr/lib -L$MARVELL_ROOTFS/lib"
export PKG_CONF_PATH=pkg-config

# Needed to build pcsxe_rearmed core
export ARCH=arm

#
# Download assets
#
if [ ! -d "${SRC}" ]; then
	git clone https://github.com/libretro/retroarch-assets.git "${SRC}"
fi

#
# Install assets
#
pushd "${SRC}"
make INSTALLDIR=${BUILD}/retroarch/.config/assets install
popd

# All done!
echo "Build complete!"
echo
echo "Put the retroarch folder onto a USB drive, insert it into your Steam Link, and run RetroArch."
