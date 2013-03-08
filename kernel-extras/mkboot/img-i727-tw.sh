#!/bin/sh

export	pwd=`readlink -f .`
echo "making ramdisk"
./mkbootfs ramdisk-i727-tw | gzip > ramdisk.gz
echo "making boot.img"
# packs the ramdisk together with the zImage at the proper locations and makes the boot.img
#./mkbootimg --cmdline "androidboot.hardware=qcom kgsl.mmutype=gpummu vmalloc=400M usb_id_pin_rework=true" --kernel $PWD/zImage --ramdisk $PWD/ramdisk.gz --base 0x40400000 -o $PWD/boot.img
#./mkbootimg --kernel $PWD/zImage --ramdisk $PWD/ramdisk.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $PWD/boot.img
./mkbootimg-sg2x --kernel $PWD/zImage --ramdisk $PWD/ramdisk.gz --cmdline "androidboot.hardware=qcom msm_watchdog.appsbark=0 msm_watchdog.enable=1 loglevel=4" -o boot.img --base 0x40400000 --pagesize 2048
rm ramdisk.gz
