#!/bin/bash

echo "Welcome to the GearKernel Build Script, please wait"

case "$1" in
        galaxys)
            VARIANT="galaxys"
            VER=""
	    BASE_SEMA_VER="GearKernel_Universal_GalaxyS_1.1.2"
	    cp -rf ics-ramdisk/ics_rec_init ics-ramdisk/gear_combo/ics_rec_init
	    cp -rf ics-ramdisk/init.d ics-ramdisk/gear_combo/files/
            ;;

        galaxysb)
            VARIANT="galaxysb"
            VER="b"
	    BASE_SEMA_VER="GearKernel_Universal_GalaxySB_1.1.2"
	    cp -rf ics-ramdisk/ics_rec_init_b ics-ramdisk/gear_combo/ics_rec_init
	    cp -rf ics-ramdisk/init.d ics-ramdisk/gear_combo/files/
            ;;

        captivate)
            VARIANT="captivate"
            VER="c"
	    BASE_SEMA_VER="GearKernel_Universal_Captivate_1.1.2"
	    cp -rf ics-ramdisk/ics_rec_init_c ics-ramdisk/gear_combo/ics_rec_init
	    cp -rf ics-ramdisk/init.d ics-ramdisk/gear_combo/files/
            ;;

        vibrant)
            VARIANT="vibrant"
            VER="v"
	    BASE_SEMA_VER="GearKernel_Universal_Vibrant_1.1.2"
	    cp -rf ics-ramdisk/ics_rec_init_v ics-ramdisk/gear_combo_v/ics_rec_init
	    cp -rf ics-ramdisk/init.d ics-ramdisk/gear_combo_v/files/
            ;;

        *)
            VARIANT="galaxys"
            VER=""
	    BASE_SEMA_VER="GearKernel_Universal_GalaxyS_1.1.2"
	    cp -rf ics-ramdisk/ics_rec_init ics-ramdisk/gear_combo/ics_rec_init
	    cp -rf ics-ramdisk/init.d ics-ramdisk/gear_combo/files/
esac

if [ "$2" = "s" ] ; then
	BASE_SEMA_VER=$BASE_SEMA_VER"s"
fi

SEMA_VER=$BASE_SEMA_VER$VER

#export KBUILD_BUILD_VERSION="2"
export LOCALVERSION="-"`echo $SEMA_VER`
#export CROSS_COMPILE=/opt/toolchains/gcc-linaro-arm-linux-gnueabihf-2012.09-20120921_linux/bin/arm-linux-gnueabihf-
export CROSS_COMPILE=~/semaphore/toolchain/arm-cortex_a8-linux-gnueabi-gearlinaro_4.8.3-2013.11/bin/arm-gnueabi-
export ARCH=arm

echo 
echo "Making ""GearKernelUni"_$VARIANT"_defconfig"

DATE_START=$(date +"%s")

make -j3 "GearKernelUni"_$VARIANT"_defconfig"

eval $(grep CONFIG_INITRAMFS_SOURCE .config)
INIT_DIR=$CONFIG_INITRAMFS_SOURCE
MODULES_DIR=`echo $INIT_DIR`files/modules
KERNEL_DIR=`pwd`
OUTPUT_DIR=../output/
CWM_DIR=./ics-ramdisk/cwm/

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
find $KERNEL_DIR -name '*.ko' -exec cp -rfv {} $MODULES_DIR \;
chmod 644 `echo $MODULES_DIR"/*"`

make -j3 zImage

cd arch/arm/boot
tar cvf `echo $SEMA_VER`.tar zImage
mv `echo $SEMA_VER`.tar ../../../$OUTPUT_DIR$VARIANT
echo "Moving to "$OUTPUT_DIR$VARIANT"/"
cd ../../../

cp -rf arch/arm/boot/zImage $CWM_DIR"boot.img"
cd $CWM_DIR
zip -r `echo $SEMA_VER`.zip *
mv  `echo $SEMA_VER`.zip ../../$OUTPUT_DIR$VARIANT"/"

cd ../../

case "$1" in
        galaxys)
		rm -r ics-ramdisk/gear_combo/ics_rec_init
		;;
	galaxysb)
		rm -r ics-ramdisk/gear_combo/ics_rec_init
		;;
	captivate)
		rm -r ics-ramdisk/gear_combo/ics_rec_init
		;;
	vibrant)
		rm -r ics-ramdisk/gear_combo_v/ics_rec_init
		;;
        *)
		rm -r ics-ramdisk/gear_combo/ics_rec_init
esac

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
