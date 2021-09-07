#!/bin/bash

curPath=$(readlink -f "$(dirname "$0")")
_UBOOT_FILE=$curPath/../u-boot/u-boot-sunxi-with-spl.bin
_DTB_FILE=$curPath/../linux/arch/arm/boot/dts/suniv-f1c100s-licheepi-nano.dtb
_KERNEL_FILE=$curPath/../linux/arch/arm/boot/zImage
_ROOTFS_FILE=$curPath/../buildroot-2017.08/output/images/rootfs.tar 
_MOD_FILE=$curPath/../linux/out/lib/modules
_IMG_SIZE=300
_UBOOT_SIZE=1
_CFG_SIZEKB=0
_P1_SIZE=16
_ADD_LITTLEVGL_DEMO=true
_IMG_FILE=firmware.dd
_SCREEN_PRAM=480272


echo "You configure your LCD parameters as $_SCREEN_PRAM"
#echo "gen img size = $_IMG_SIZE MB"
#_ROOTFS_SIZE=`gzip -l $_ROOTFS_FILE | sed -n '2p' | awk '{print $2}'`
#_ROOTFS_SIZE=`echo "scale=3;$_ROOTFS_SIZE/1024/1024" | bc`
_MOD_SIZE=`du $_MOD_FILE --max-depth=0 | cut -f 1`
_MOD_SIZE=`echo "scale=3;$_MOD_SIZE/1024" | bc`
#_MIN_SIZE=`echo "scale=3;$_UBOOT_SIZE+$_P1_SIZE+$_ROOTFS_SIZE+$_MOD_SIZE+$_CFG_SIZEKB/1024" | bc`
#echo  "min img size = $_MIN_SIZE MB"
#_FREE_SIZE=`echo "$_IMG_SIZE-$_MIN_SIZE"|bc`
#echo "free space=$_FREE_SIZE MB"
# fi

rm $_IMG_FILE
if [ ! -e $_IMG_FILE ] ; then
    echo  "gen empty img..."
    dd if=/dev/zero of=$_IMG_FILE bs=1M count=$_IMG_SIZE
fi
if [ $? -ne 0 ]
then echo "getting error in creating dd img!"
    exit
fi

_LOOP_DEV=$(sudo losetup -f)
if [ -z $_LOOP_DEV ]
then echo  "can not find a loop device!"
    exit
fi

sudo losetup $_LOOP_DEV $_IMG_FILE
if [ $? -ne 0 ]
then echo "dd img --> $_LOOP_DEV error!"
    sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
fi

#############################################
#  			BOOT FROM TF CARD				#
echo "creating partitions for tf image ..."
#blockdev --rereadpt $_LOOP_DEV >/dev/null 2>&1
# size only can be integer

cat <<EOT |sudo  sfdisk $_IMG_FILE
${_UBOOT_SIZE}M,${_P1_SIZE}M,c
,,L
EOT

sleep 2
sudo partx -u $_LOOP_DEV
sudo mkfs.vfat ${_LOOP_DEV}p1 ||exit
sudo mkfs.ext4 ${_LOOP_DEV}p2 ||exit
if [ $? -ne 0 ]
then echo "error in creating partitions"
    sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
    #sudo partprobe $_LOOP_DEV >/dev/null 2>&1 && exit
fi

echo  "writing u-boot-sunxi-with-spl to $_LOOP_DEV"
# sudo dd if=/dev/zero of=$_LOOP_DEV bs=1K seek=1 count=1023  # clear except mbr
sudo dd if=$_UBOOT_FILE of=$_LOOP_DEV bs=1024 seek=8
if [ $? -ne 0 ]
then echo "writing u-boot error!"
    sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
    #sudo partprobe $_LOOP_DEV >/dev/null 2>&1 && exit
fi

sudo sync
mkdir -p p1 >/dev/null 2>&1
mkdir -p p2 > /dev/null 2>&1
sudo mount ${_LOOP_DEV}p1 p1
sudo mount ${_LOOP_DEV}p2 p2
echo  "copy boot and rootfs files..."
sudo rm -rf  p1/* && sudo rm -rf p2/*

sudo cp $_KERNEL_FILE p1/zImage &&\
sudo cp $_DTB_FILE p1/ &&\
sudo cp boot.scr p1/ &&\
echo "p1 done~"
sudo tar xf $_ROOTFS_FILE -C p2/ &&\
_ROOTFS_SIZE=`du p2/ --max-depth=0 | cut -f 1`
_ROOTFS_SIZE=`echo "scale=3;$_ROOTFS_SIZE/1024" | bc`
echo "p2 done~"
sudo mkdir -p p2/lib/modules/${_KERNEL_VER}-next-20180202-licheepi-nano+/ &&\
sudo cp -r $_MOD_FILE/*  p2/lib/modules/${_KERNEL_VER}-next-20180202-licheepi-nano+/
echo "modules done~"

if [ $_ADD_LITTLEVGL_DEMO = true ]
echo "we gonna add littleVgl demo in your dir /root"
then sudo mkdir -p p2/lib/syjTest &&\
    sudo cp $curPath/../littleVGL/demo p2/lib/syjTest
    sudo cp $curPath/../InforNES/InfoNES097JRC1_SDL/sdl/InfoNES p2/lib/syjTest
    sudo cp $curPath/sample.avi p2/lib/syjTest
fi

if [ $? -ne 0 ]
then echo "copy files error! "
    sudo losetup -d $_LOOP_DEV >/dev/null 2>&1
    sudo umount ${_LOOP_DEV}p1  ${_LOOP_DEV}p2 >/dev/null 2>&1
    exit
fi
echo "The tf card image-packing task done~"


sudo sync
sudo umount p1 p2  && sudo losetup -d $_LOOP_DEV
if [ $? -ne 0 ]
then echo "umount or losetup -d error!!"
    exit
fi
    

_MIN_SIZE=`echo "scale=3;$_UBOOT_SIZE+$_P1_SIZE+$_ROOTFS_SIZE+$_MOD_SIZE+$_CFG_SIZEKB/1024" | bc`
echo  "min img size = $_MIN_SIZE MB"
_FREE_SIZE=`echo "$_IMG_SIZE-$_MIN_SIZE"|bc`
echo "free space=$_FREE_SIZE MB"

echo "The $_IMG_FILE has been created successfully!"
echo "gen img size = $_IMG_SIZE MB"
echo "min img size = $_MIN_SIZE MB"
echo "free space = $_FREE_SIZE MB"
exit






