#!/bin/bash
BASEDIR=.
NODEBOARD=ThingNode                         # Support ThingNode

#JN_TARGET_BOARD=pi-modelb-v2   # raspberry-pi
JN_TARGET_BOARD=tl-wr703n-v1   # TP-Link WR703N-v1

[ -z "${JN_TARGET_BOARD}" ]  && JN_TARGET_BOARD=tl-wr703n-v1  # TP-Link WR703N-v1

#store openwrt dl packages 
DOWNLOAD_DIR=downloads
[ ! -d ${DOWNLOAD_DIR} ] && mkdir ${DOWNLOAD_DIR} 

OPENWRT_CONFIG=""
OPENWRT_BUILDPATH=""
[ "${JN_TARGET_BOARD}" == "tl-wr703n-v1" ] && OPENWRT_CONFIG=config.${NODEBOARD}.703n && OPENWRT_BUILDPATH=${BASEDIR}/targets/tlwr703n
[ "${JN_TARGET_BOARD}" == "pi-modelb-v2" ] && OPENWRT_CONFIG=config.${NODEBOARD}.raspberry-pi && OPENWRT_BUILDPATH=${BASEDIR}/targets/raspi
[ -z "${OPENWRT_CONFIG}" ] && echo "[ERROR]: Target board not suported" && exit 1

which wget > /dev/null && DL_PROG=wget && DL_PARA="-nv -O"
which curl > /dev/null && DL_PROG=curl && DL_PARA="-L -o"

# According to http://wiki.openwrt.org/doc/howto/build
unset SED
unset GREP_OPTIONS
[ "`id -u`" == "0" ] && echo "[ERROR]: Please use non-root user" && exit 1
CORE_NUM="$(expr $(nproc) + 1)"
[ -z "$CORE_NUM" ] && CORE_NUM=2

VERSION=20140503

## Version
if [ "$#" == "0" ]; then
    $0 --help
    exit 0
elif [ "$1" == "--version" ] || [ "$1" == "--help" ]; then
    echo "\

Usage: $0 [--version] [--help] [--clone] [--build] [--menuconfig]

     --version
     --help             Display help message

     --clone            Get all source code, ONLY NEED ONCE

     --build            Get .config file and build firmware

     --menuconfig       Config openWRT

     JN_TARGET_BOARD   Environment variable, available target:
                        tl-wr703n-v1, pi-modelb-v2
                        use tl-wr703n-v1 if unset

Written By: Mikeqin <fengling.qin@gmail.com>

                                                     Version: ${VERSION}"
    exit 0
fi

if [ ! -d ${OPENWRT_BUILDPATH} ]; then
    echo "[ERROR]: build path is not exist!" && exit 1
fi

if [ "$1" == "--clone" ]; then
    #$DL_PROG https://raw.github.com/BitSyncom/cgminer-openwrt-packages/master/cgminer/data/${OPENWRT_CONFIG} $DL_PARA .config
    make -C ${OPENWRT_BUILDPATH} all
    exit $?
fi

if [ "$1" == "--build" ]; then
    if [ -d ${OPENWRT_BUILDPATH}/backfire ]; then
	echo "find backfire,then clean them"
#	[ "$?" == "0" ] && make -C ${OPENWRT_BUILDPATH}/backfire clean
    fi

    #yes "" | make oldconfig
    make -C ${OPENWRT_BUILDPATH}/backfire -j${CORE_NUM} V=s IGNORE_ERRORS=m || make -C ${OPENWRT_BUILDPATH}/backfire V=s IGNORE_ERRORS=m
    exit $?
fi

if [ "$1" == "--menuconfig" ]; then
   make -C ${OPENWRT_BUILDPATH}/backfire menuconfig
fi
 
