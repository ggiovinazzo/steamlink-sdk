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
SRC="${PWD}/retroarch-core-src"

# Extra environment variables for this build
export OS=Linux
export CC="${CROSS}gcc"
export CPP="${CROSS}cpp"
export CXX="${CROSS}g++"
export CFLAGS="--sysroot=$MARVELL_ROOTFS -DLINUX=1 -DEGL_API_FB=1 -marm"
export LDFLAGS="--sysroot=$MARVELL_ROOTFS -static-libgcc -static-libstdc++ -lEGL"
export INCLUDE_DIRS="-I$MARVELL_ROOTFS/usr/include -I$MARVELL_ROOTFS/usr/include/EGL -I$MARVELL_ROOTFS/usr/include/SDL2 -I${MARVELL_ROOTFS}/usr/include/GLES2 -I$MARVELL_ROOTFS/usr/include/freetype2"
export LIBRARY_DIRS="-L$MARVELL_ROOTFS/usr/lib -L$MARVELL_ROOTFS/lib"
export PKG_CONF_PATH=pkg-config

#
# Load cores helper config
#
source "${TOP}/cores_helper.sh"

#
# Download the source for cores
#
if [ ! -d "${SRC}" ]; then
	git clone https://github.com/libretro/libretro-super.git "${SRC}"
fi

#
# Build cores
#
pushd "${SRC}"
    ./libretro-fetch.sh $CORES
    for c in "${CORES_LIST[@]}"; do
        call_build $c
    done
popd

#
# Install it
#
export DESTDIR="${BUILD}/retroarch"
export CONFDIR="${DESTDIR}/.config"
export CORESDIR="${BUILD}/retroarch/cores"
mkdir -p "${DESTDIR}"
mkdir -p "${DESTDIR}/roms"
mkdir -p "${DESTDIR}/saves/states"
mkdir -p "${DESTDIR}/screenshots"
mkdir -p "${CORESDIR}"
mkdir -p "${CONFDIR}"
mkdir -p "${CONFDIR}/filters/audio" "${CONFDIR}/bundle/sub" "${CONFDIR}/bundle/src"
mkdir -p "${CONFDIR}/cache" "${CONFDIR}/database/rdb" "${CONFDIR}/history"
mkdir -p "${CONFDIR}/downloads" "${CONFDIR}/database/cursors" "${CONFDIR}/remaps"
mkdir -p "${CONFDIR}/autoconfig" "${CONFDIR}/info" "${CONFDIR}/overlay"
mkdir -p "${CONFDIR}/playlists" "${CONFDIR}/config" "${CONFDIR}/system"
mkdir -p "${CONFDIR}/thumbnails" "${CONFDIR}/filters/video" "${CONFDIR}/shaders"

# Copy the files to the app directory then strip debug symbols
cp -v ${SRC}/dist/unix/* ${CORESDIR}
for CORE_SO in $( ls ${CORESDIR}/* ); do
    $STRIP -s "${CORE_SO}"
done

# All done!
echo
echo "Build complete! [`ls -1 ${CORESDIR}| wc -l`/${#CORES_LIST[@]}] cores built."
echo
echo "Put the retroarch folder onto a USB drive, insert it into your Steam Link, and run RetroArch."
