#!/bin/bash

case "$1" in
        galaxys)
            VARIANT="galaxys"
            VER=""
	    BASE_SEMA_VER="GearKernel_ICS_GalaxyS_V0.1"
            ;;

        galaxysb)
            VARIANT="galaxysb"
            VER="b"
	    BASE_SEMA_VER="GearKernel_ICS_GalaxySB_V0.1"
            ;;

        captivate)
            VARIANT="captivate"
            VER="c"
	    BASE_SEMA_VER="GearKernel_ICS_Captivate_V0.1"
            ;;

        vibrant)
            VARIANT="vibrant"
            VER="v"
	    BASE_SEMA_VER="GearKernel_ICS_Vibrant_V0.1"
            ;;

        *)
            VARIANT="galaxys"
            VER=""
	    BASE_SEMA_VER="GearKernel_ICS_GalaxyS_V0.1"
esac

if [ "$2" = "s" ] ; then
	BASE_SEMA_VER=$BASE_SEMA_VER"s"
fi

SEMA_VER=$BASE_SEMA_VER$VER

#export KBUILD_BUILD_VERSION="2"
export LOCALVERSION="-"`echo $SEMA_VER`
#export CROSS_COMPILE=/opt/toolchains/gcc-linaro-arm-linux-gnueabihf-2012.09-20120921_linux/bin/arm-linux-gnueabihf-
export CROSS_COMPILE=/semaphore/toolchain/bin/arm-gnueabi-
export ARCH=arm

echo 
echo "Making ""semaphore"_$VARIANT"_defconfig"

DATE_START=$(date +"%s")

make -j3 "semaphore"_$VARIANT"_defconfig"

eval $(grep CONFIG_INITRAMFS_SOURCE .config)
INIT_DIR=$CONFIG_INITRAMFS_SOURCE
MODULES_DIR=`echo $INIT_DIR`files/modules
KERNEL_DIR=`pwd`
OUTPUT_DIR=/semaphore/output/
CWM_DIR=/semaphore/samsung-kernel-aries/ics-ramdisk/cwm/

echo "LOCALVERSION="$LOCALVERSION
echo "CROSS_COMPILE="$CROSS_COMPILE
echo "ARCH="$ARCH
echo "INIT_DIR="$INIT_DIR
echo "MODULES_DIR="$MODULES_DIR
echo "KERNEL_DIR="$KERNEL_DIR
echo "OUTPUT_DIR="$OUTPUT_DIR
echo "CWM_DIR="$CWM_DIR

if [ "$2" = "s" ] ; then
        echo "CONFIG_S5P_HUGEMEM=y" >> .config
fi



make -j3 modules

rm `echo $MODULES_DIR"/*"`
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
chmod 644 `echo $MODULES_DIR"/*"`

make -j3 zImage

cd arch/arm/boot
tar cvf `echo $SEMA_VER`.tar zImage
mv `echo $SEMA_VER`.tar ../../../../../../$OUTPUT_DIR$VARIANT
echo "Moving to "$OUTPUT_DIR$VARIANT"/"
cd ../../../

cp arch/arm/boot/zImage $CWM_DIR"boot.img"
cd $CWM_DIR
zip -r `echo $SEMA_VER`.zip *
mv  `echo $SEMA_VER`.zip ../../../../$OUTPUT_DIR$VARIANT"/"

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
