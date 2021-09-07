/*
 * Configuration settings for new Allwinner F-series (suniv) CPU
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#ifndef __CONFIG_H
#define __CONFIG_H

#define CONFIG_SUNXI_USB_PHYS 1

/*
 * Include common sunxi configuration where most the settings are
 */
#include <configs/sunxi-common.h>

/* 添加以下代码（mmc 0为TF卡，1是第一分区，文件系统为fat32，把zImage和dtb文件拷入DRAM）*/
#define CONFIG_BOOTCOMMAND	"fatload mmc 0:1 0x80008000 zImage; "  \
                            "fatload mmc 0:1 0x80C00000 suniv-f1c100s-licheepi-nano.dtb; " \
                            "bootz 0x80008000 - 0x80C00000;"

/* 继续添加（linux将使用uart0进行交互，死机5s重启，根文件系统在mmc0（tf卡）第二分区（EXT4)，等待 mmc 设备初始化完成以后再挂载，开启读写权限） */
#define CONFIG_BOOTARGS   "console=ttyS0,115200 panic=5 root=/dev/mmcblk0p2 rootwait rw "



#endif /* __CONFIG_H */
