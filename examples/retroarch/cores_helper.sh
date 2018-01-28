#!/bin/bash
#

CORES="fbalpha2012 fceumm gambatte genesis_plus_gx mednafen_pce_fast mgba nestopia nxengine pcsx_rearmed picodrive prboom snes9x2002 stella parallel_n64"
CORES_LIST=($CORES)

function pcsx_rearmed(){
    # Needed to build pcsxe_rearmed core
    export ARCH=arm
}

function parallel_n64(){
    export ARCH=arm
    export INCFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"
    sed -i "s/FORCE_GLES=0/FORCE_GLES=1/" libretro-parallel_n64/Makefile
    sed -i "s@COREFLAGS :=@COREFLAGS = ${INCLUDE_DIRS} ${LIBRARY_DIRS}@" libretro-parallel_n64/Makefile
}

function call_build(){
    # Exec in subshell to avoid env variables pollution
    ( type -t $1 && eval $1; ./libretro-build.sh $1 )
}
