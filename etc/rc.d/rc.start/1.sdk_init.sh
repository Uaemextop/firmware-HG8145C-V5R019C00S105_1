#!/bin/sh
#添加lib的环境变量

[ -n $LD_LIBRARY_PATH ] && export LD_LIBRARY_PATH=/lib:/lib/exlib:/lib/omci_module:/lib/oam_module:/usr/osgi/lib:/usr/osgi/lib/aarch32:/usr/osgi/lib/aarch32/jli:/usr/osgi/lib/aarch32/server:/usr/lib/glib-2.0/;

export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

#加载故障自愈的ko
if [ -f /lib/modules/wap/hw_ssp_sys_res.ko ];then
	insmod /lib/modules/wap/hw_ssp_sys_res.ko
fi

# 持裁剪jffs2文件系统，完成之后恢复log
#echo "Mount Jffs2 in 1.sdk_init..."

chmod 777 /var /tmp /dev/null

mount -t ubifs -o sync /dev/ubi0_13 /mnt/jffs2/
if [ ! -f "/mnt/jffs2/mount_ok" ]; then
	echo "mount_ok" > "/mnt/jffs2/mount_ok"
	umount /mnt/jffs2
	mount -t ubifs -o sync /dev/ubi0_13 /mnt/jffs2/
	if [  $? != 0  ] || [ ! -f "/mnt/jffs2/mount_ok" ]; then
		echo "Failed to mount jffs2, reboot system" | ls -l /mnt/jffs2
		reboot
	fi
fi

if [ ! -d "/mnt/ftproot" ]; then
	mkdir /mnt/ftproot
	chmod 755 /mnt/ftproot
fi


# 如果jffs2目录下有midinfo.debug这个文件，就读取里面的mid，并打开
if [ -f /mnt/jffs2/midinfo.debug ]; then
while read midinfo; do
	mid set $midinfo 1;
done < /mnt/jffs2/midinfo.debug
rm -f /mnt/jffs2/midinfo.debug
fi

Reloadlog

[ -f /mnt/jffs2/stop ] && exit

[ -f /lib/modules/linux/kernel/net/ipv6/ipv6.ko ] && insmod /lib/modules/linux/kernel/net/ipv6/ipv6.ko
#[ -f /lib/modules/linux/kernel/net/ipv4/tunnel4.ko ] && insmod /lib/modules/linux/kernel/net/ipv4/tunnel4.ko
#[ -f /lib/modules/linux/kernel/net/ipv6/sit.ko ] && insmod /lib/modules/linux/kernel/net/ipv6/sit.ko
[ -f /lib/modules/3.10.53-HULK2/kernel/drivers/block/loop.ko ] && insmod /lib/modules/3.10.53-HULK2/kernel/drivers/block/loop.ko

HW_LANMAC_TEMP="/var/hw_lanmac_temp"

HW_BOARD_LANMAC="00:00:00:00:00:02"

echo -n "Rootfs time stamp:"
cat /etc/timestamp

echo -n "SVN label(ont):"
cat /etc/wap/ont_svn_info.txt

#echo 100 > /proc/sys/vm/pagecache_ratio
#echo 3 > /proc/sys/vm/drop_caches
# SA1456C插着U盘切区失败问题，将智能的消息队列msgmni限制放大
if [ -f /bin/osgi_proxy ]; then
	echo 96 > /proc/sys/kernel/msgmni
else
	echo 64 > /proc/sys/kernel/msgmni
fi
echo 2048 > /proc/sys/net/ipv4/route/max_size
MIN_FREE_INFO=`cat /proc/sys/vm/min_free_kbytes`
echo 8192 > /proc/sys/vm/min_free_kbytes 

#避免eth0发RS
[ -f /proc/sys/net/ipv6/conf/default/forwarding ] && echo 1 > /proc/sys/net/ipv6/conf/default/forwarding

# Close/Open(0/8) the printk for debug
echo 8 > /proc/sys/kernel/printk

# 配置网络参数
echo 128 > /proc/sys/net/core/dev_weight
echo 640 > /proc/sys/net/core/netdev_budget
echo 1300 > /proc/sys/net/core/netdev_max_backlog
echo 163840 > /proc/sys/net/core/rmem_default
echo 163840 > /proc/sys/net/core/rmem_max
echo 163840 > /proc/sys/net/core/wmem_default
echo 163840 > /proc/sys/net/core/wmem_max
echo 5490 7320 10980 > /proc/sys/net/ipv4/tcp_mem
echo 5490 7320 10980 > /proc/sys/net/ipv4/udp_mem
echo 4096 87380 234240 > /proc/sys/net/ipv4/tcp_rmem
echo 4096 16384 234240 > /proc/sys/net/ipv4/tcp_wmem

sysctl -w net.ipv6.ip6frag_high_thresh=262144                
sysctl -w net.ipv6.ip6frag_low_thresh=196608                 
sysctl -w net.netfilter.nf_conntrack_frag6_high_thresh=262144
sysctl -w net.netfilter.nf_conntrack_frag6_low_thresh=196608 
sysctl -w net.ipv4.neigh.default.base_reachable_time=300
sysctl -w net.ipv6.neigh.default.base_reachable_time=300
 
echo !reload > /proc/wap_proc/voice_log
echo !reload > /proc/wap_proc/nff_log

[ -f /mnt/jffs2/Equip.sh ] && /bin/Equip.sh && exit

var_xpon_mode=`cat /mnt/jffs2/hw_boardinfo | grep "0x00000001" | cut -c38-38`
echo "xpon_mode:${var_xpon_mode}"

echo ${var_xpon_mode}>>/var/var_xpon_mode

echo "User init start......"

# load hisi modules
if [ -f /mnt/jffs2/TranStar/hi_sysctl.ko ]; then
	  cd /mnt/jffs2/TranStar/
	  echo "Loading the Temp HISI SD511X modules: "
else
	  cd /lib/modules/hisi_sdk
	  echo "Loading the HISI SD511X modules: "
fi
		
    insmod hi_sysctl.ko
    insmod hi_spi.ko	

   
tempChipType1=`md 0x10100800 1`
tempChipType=`echo $tempChipType1 | sed 's/.*:: //' | sed 's/[0-9][0-9]00//' | cut -b 1-4`

if [ $tempChipType -eq 5115 ]; then
    insmod hi_gpio_5115.ko
else
    insmod hi_gpio.ko
fi    
    
    	
    insmod hi_gpio.ko
    insmod hi_i2c.ko
    insmod hi_timer.ko
    insmod hi_serdes.ko	

    insmod hi_hw.ko
    insmod hi_uart.ko
    insmod hi_dma.ko
if [ -e /mnt/jffs2/PhyPatch ]; then
    echo "phy patch path is /mnt/jffs2/PhyPatch/ "
    if [ $tempChipType -eq 5115 ]; then
        insmod hi_bridge_5115.ko	pPhyPatchPath="/mnt/jffs2/PhyPatch/"
    else    
        insmod hi_bridge.ko pPhyPatchPath="/mnt/jffs2/PhyPatch/"
    fi
else
    if [ $tempChipType -eq 5115 ]; then
        insmod hi_bridge_5115.ko	
    else    
        insmod hi_bridge.ko
    fi
fi
    insmod /lib/modules/wap/pkt_ring.ko
    insmod hi_pie.ko tx_chk=0
    insmod hi_ponlp.ko
	
if [ ${var_xpon_mode} == "5" ]; then	
	insmod hi_xgpon.ko
	insmod hi_xepon.ko
elif [ ${var_xpon_mode} == "6" ]; then
	insmod hi_xgpon.ko
	insmod hi_xepon.ko
elif [ ${var_xpon_mode} == "7" ]; then
	insmod hi_xgpon.ko
	insmod hi_xepon.ko
else
    insmod hi_gpon.ko
    insmod hi_epon.ko
fi    

if [ $tempChipType -eq 5115 ]; then
    insmod hi_l3_5115.ko
else    	
    insmod hi_l3.ko
fi    
    insmod hi_oam.ko	     
    insmod hi_sci.ko
    insmod hi_mdio.ko	
    #insmod hi_adp_cnt.ko

cd /

# set lanmac 
getlanmac $HW_LANMAC_TEMP
if [ 0  -eq  $? ]; then
    read HW_BOARD_LANMAC < $HW_LANMAC_TEMP
    echo "ifconfig eth0 hw ether $HW_BOARD_LANMAC"
    ifconfig eth0 hw ether $HW_BOARD_LANMAC
fi

# delete temp lanmac file
if [ -f $HW_LANMAC_TEMP ]; then
    rm -f $HW_LANMAC_TEMP
fi

# activate ethernet drivers

mtu_spec=`GetSpec SPEC_LOWER_LAYER_MAX_MTU`
ifconfig eth0 192.168.100.1 up
ifconfig eth0 mtu $mtu_spec

mkdir /var/tmp

if [ -f /lib/modules/linux/extra/arch/arm/mach-hisi/pcie.ko ]; then
	insmod /lib/modules/linux/extra/arch/arm/mach-hisi/pcie.ko
	insmod /lib/modules/wap/hw_module_acp.ko
fi

echo "Loading the EchoLife WAP modules: LDSP"

# hw_module_common.ko hw_module_hlp.ko are needed by all of ko

insmod /lib/modules/wap/hw_module_common.ko
insmod /lib/modules/wap/hw_module_i2c.ko
insmod /lib/modules/wap/hw_module_gpio.ko

insmod /lib/modules/wap/hw_module_uart.ko
insmod /lib/modules/wap/hw_module_battery.ko
insmod /lib/modules/wap/hw_module_optic.ko
insmod /lib/modules/wap/hw_module_key.ko
insmod /lib/modules/wap/hw_module_led.ko
insmod /lib/modules/wap/hw_module_rf.ko

if [ -f /lib/modules/wap/hw_module_sim.ko ];then
	insmod /lib/modules/wap/hw_module_sim.ko
fi
#Zigbee和Zwave
if [ -f /lib/modules/wap/hw_module_iot.ko ];then
	insmod /lib/modules/wap/hw_module_iot.ko
fi

insmod /lib/modules/wap/hw_module_dev.ko
#dm产品侧ko,需在hw_module_dev.ko加载后加载
#判断/mnt/jffs2/customize_xml.tar.gz文件是否存在，存在解压
if [ -e /mnt/jffs2/customize_xml.tar.gz ]
then
    #解析customize_relation.cfg
    tar -xzf /mnt/jffs2/customize_xml.tar.gz -C /mnt/jffs2/ customize_xml/customize_relation.cfg  
fi

insmod /lib/modules/wap/hw_dm_pdt.ko
insmod /lib/modules/wap/hw_module_feature.ko
insmod /lib/modules/wap/hw_module_mpcp.ko
#NFC
if [[ -f /lib/modules/wap/hw_module_nfc_st.ko && -f  /lib/modules/wap/hw_module_nfc.ko ]];then
	insmod /lib/modules/wap/hw_module_nfc_st.ko
	insmod /lib/modules/wap/hw_module_nfc.ko
fi

if [ ${var_xpon_mode} == "5" ]; then	
	 insmod /lib/modules/wap/hw_module_xgploam.ko
else
   insmod /lib/modules/wap/hw_module_ploam.ko
fi

   insmod /lib/modules/wap/hw_module_phy.ko 
if [ -e /var/bcm84846.txt ]; then 
	 insmod /lib/modules/wap/hw_ker_phy_bcm84846.ko
elif [ -e /var/bcm50612e.txt ]; then 
	 insmod /lib/modules/wap/hw_ker_phy_bcm50612e.ko
elif [ -e /var/m88e151x.txt ]; then 
	 insmod /lib/modules/wap/hw_ker_phy_m88e151x.ko
fi

if [ -f /lib/modules/wap/hw_module_ppm.ko ];then
	insmod /lib/modules/wap/hw_module_ppm.ko
fi

insmod /lib/modules/wap/hw_module_amp.ko
insmod /lib/modules/wap/hw_module_gmac.ko
insmod /lib/modules/wap/hw_module_emac.ko
#insmod /lib/modules/wap/hw_module_wifi.ko

#产品侧DM加载之后就可以通过/proc/wap_proc/chip_attr文件获取芯片类型
#再根据芯片类型给kbox分配512k高端内存(只是网关产品才添加)
#var_soc_type_kbox_temp=5115H;var_soc_type_kbox=5115
var_soc_attr_kbox=`GetChipDes`
var_soc_type_kbox_temp=`echo $var_soc_attr_kbox | sed 's/.*\"SD//' | sed 's/V[0-9]*\"//' | tr -d '[\015]'`
var_soc_type_kbox=$(echo $var_soc_type_kbox_temp | cut -b 1-4)
echo 102400 > /sys/module/kbox/parameters/kbox_default_reg_size

if [ $var_soc_type_kbox -eq 5113 ] ; then
	echo "0x9337F000 512K" > /proc/kbox/mem
elif [ $var_soc_type_kbox -eq 5115 ] ; then
	echo "0x80880000 512K" > /proc/kbox/mem
elif [ $var_soc_type_kbox -eq 5116 ] ; then
	if [ "$var_soc_type_kbox_temp" == "5116T" ] || [ "$var_soc_type_kbox_temp" == "5116H" ] ; then
		echo "0x80880000 512K" > /proc/kbox/mem
	elif [ "$var_soc_type_kbox_temp" == "5116L" ] ; then
		echo "0x80480000 512K" > /proc/kbox/mem
	elif [ "$var_soc_type_kbox_temp" == "5116S" ] ; then
		echo "0x80080000 512K" > /proc/kbox/mem
	else
		echo "(!5116T/H/L/S)can not configure the kbox!!!"
	fi
elif [ $var_soc_type_kbox -eq 5118 ] ; then
	echo "0x82080000 512K" > /proc/kbox/mem
else
	echo "(!5113&&!5115&&!5116)can not configure the kbox!!!"
fi

# pcie use stronly order maps
if [ "$var_soc_type_kbox_temp" == "5116T" ]; then
		#echo "base=0x40000000 size=0xa00000 type=4" > /proc/mtrc
		#echo "base=0x58000000 size=0xa00000 type=4" > /proc/mtrc
		echo "base=0x40000000 size=0x20000000 type=4" > /proc/mtrc
fi

var_kbox_config=`cat /proc/kbox/mem`
echo "kbox config(Addr---Size)="$var_kbox_config

#打印进程快照，必须在kbox配置之后
insmod  /lib/modules/3.10.53-HULK2/mts/rtos_snapshot.ko log_size=104

cd /var
dlw 1 > lastsysinfo
var_size=`stat -c %s /var/lastsysinfo`
if [ $var_size -gt 1024 ]
then
    echo "save sys info"
    cat /proc/kbox/regions/panic >> lastsysinfo
    tar -czf lastsysinfo.tar.gz lastsysinfo
fi
rm -rf lastsysinfo
cd /

    
#设置打印机缓存大小
cups_buff=`GetSpec SSMP_SPEC_CUPS_BUFSIZE | tr -d ' \t\r\n'`
mkdir -p /var/spool/cups
mount -t tmpfs -o nodev,nosuid,size=${cups_buff}m,mode=755 none /var/spool/cups

#挂载app分区


ctrg_support=`GetFeature HW_SSMP_FEATURE_CTRG`
#通过特性开关来挂载opt
echo "@@@@@@ ctrg_support is $ctrg_support @@@@@@"
if [ $ctrg_support = 1 ] ;then

    #挂载天翼网关要求的分区目录，/opt/upt/framework1，/opt/upt/framework2，/opt/upt/apps
    #mount -t squashfs /dev/mtdblock17 /opt/upt/framework
    mount -t ubifs -o sync /dev/ubi0_16 /opt/upt/apps
    if [ ! -f "/mnt/jffs2/mount_apps_ok" ]; then
    	echo "mount_apps_ok" > "/mnt/jffs2/mount_apps_ok"
    	umount /opt/upt/apps
    	mount -t ubifs -o sync /dev/ubi0_16 /opt/upt/apps
    	if [  $? != 0  ] || [ ! -f "/mnt/jffs2/mount_apps_ok" ]; then
    		echo "Failed to mount apps, reboot system" | ls -l /mnt/jffs2
    		reboot
    	fi
    fi  

	mkdir -p /var/exrootfs
	#if [ -c "/dev/ubi0_17" ] ; then
	#	mount -t squashfs /dev/mtdblock20 /var/exrootfs
	#	if [ ! -f "/var/exrootfs/mount_exrootfs_ok" ]; then
	#		echo "mount_exrootfs_ok" > "/var/exrootfs/mount_exrootfs_ok"
	#		umount /var/exrootfs
	#		mount -t squashfs /dev/mtdblock20 /var/exrootfs
	#		if [  $? != 0  ] || [ ! -f "/var/exrootfs/mount_exrootfs_ok" ]; then
	#			echo "Failed to mount exrootfs" | ls -l /v
	#		fi
	#	fi  
#	else
		#loadexfs
#	fi

	loadexfs

    #电信天翼网关挂载cgroup
    cgroot="/sys/fs/cgroup"
    subsys="blkio cpu cpuacct cpuset devices freezer memory net_cls net_prio ns perf_event"
    #subsys="blkio cpu cpuacct cpuset devices freezer memory"
    mount -t tmpfs cgroup_root "${cgroot}"
    for ss in $subsys; do
        mkdir -p "$cgroot/$ss"
        mount -t cgroup -o "$ss" "$ss" "$cgroot/$ss"
    done
    echo "ctrg cgroup mount done!"
 
else
    if [ -c "/dev/ubi0_14" ]; then
        if [ ! -d "/mnt/jffs2/app" ]; then
            mkdir /mnt/jffs2/app
        fi
        mount -t ubifs -o sync /dev/ubi0_14 /mnt/jffs2/app
        if [ ! -f "/mnt/jffs2/mount_osgi_ok" ]; then
            echo "mount_ok" > "/mnt/jffs2/mount_osgi_ok"
            umount /mnt/jffs2/app
            mount -t ubifs -o sync /dev/ubi0_14 /mnt/jffs2/app
            if [  $? != 0  ] || [ ! -f "/mnt/jffs2/mount_osgi_ok" ]; then
                echo "Failed to mount app, reboot system" | ls -l /mnt/jffs2/app
                reboot
            fi
        fi
    fi 
fi
            
#通过特性开关来启动cwmp进程
resume_enble=`GetFeature HW_SSMP_FEATURE_TR069`
echo $resume_enble > /var/resume_enble_cwmp

. /usr/bin/init_topo_info.sh

qoe_enble=`GetFeature HW_SSMP_FT_CWMP_PROBE_SERVER`
if [ $qoe_enble = 1 ];then
	if [ -e /mnt/jffs2/jscmcc.qosmonloader.cpk ]; then
		rm -rf /mnt/jffs2/vixtel
		mkdir -p /mnt/jffs2/vixtel
		cd /mnt/jffs2/vixtel
		tar -xzf /mnt/jffs2/jscmcc.qosmonloader.cpk -C ./
		#mv -f /mnt/jffs2/vixtel/xrobot /mnt/jffs2/vixtel/monitor.wan.bin
		chmod -R 777 /mnt/jffs2/vixtel
		rm -f /mnt/jffs2/jscmcc.qosmonloader.cpk
		cd -
	fi
fi
echo "pots_num="$pots_num
echo " usb_num="$usb_num
echo "hw_route="$hw_route
echo "   l3_ex="$l3_ex
echo "    ipv6="$ipv6
rm -f /var/topo.sh

mem_totalsize=`cat /proc/meminfo | grep MemTotal | cut -c11-22`
echo "Read MemInfo Des:"$mem_totalsize



# pots ko
if [ $pots_num -ne 0 ]
then 
    insmod /lib/modules/wap/hw_module_highway.ko
    insmod /lib/modules/wap/hw_module_spi.ko
    insmod /lib/modules/wap/hw_module_codec.ko
    if [ $pots_num -eq 1 ]
    then
         if [ -e /var/si32176.txt ]
         then
             insmod /lib/modules/wap/hw_ker_codec_si32176.ko
	     elif [ -e /var/pef3201.txt ]
	     then
	         insmod /lib/modules/wap/hw_ker_codec_pef3201.ko
	     elif [ -e /var/pef3100x.txt ]
	     then
	         insmod /lib/modules/wap/hw_ker_codec_pef31002.ko
	     elif [ -e /var/le964x.txt ]
	     then
	         insmod /lib/modules/wap/hw_ker_codec_le964x.ko    
	     else
             insmod /lib/modules/wap/hw_ker_codec_ve8910.ko
	     fi
    else
        if [ -e /var/le964x.txt ]
        then
             insmod /lib/modules/wap/hw_ker_codec_le964x.ko
		elif [ -e /var/pef3100x.txt ]
		then
             insmod /lib/modules/wap/hw_ker_codec_pef31002.ko		
        else     
             insmod /lib/modules/wap/hw_ker_codec_pef3201.ko
        fi
    fi
fi

#if file is existed ,don't excute
if [ $usb_num -ne 0 ]
then
    cd /lib/modules/linux/
    if [ -f ./extra/drivers/usb/storage/usb-storage.ko ]; then
	 #  insmod ./kernel/fs/nls/nls_base.ko
	    insmod ./kernel/fs/nls/nls_ascii.ko
	    insmod ./kernel/fs/nls/nls_cp437.ko
	    insmod ./kernel/fs/nls/nls_utf8.ko
	    insmod ./kernel/fs/nls/nls_cp936.ko
	    insmod ./kernel/fs/fat/fat.ko
	    insmod ./kernel/fs/fat/vfat.ko
	    insmod ./kernel/fs/fuse/fuse.ko
	    insmod ./kernel/fs/overlayfs/overlayfs.ko
	    insmod ./kernel/drivers/scsi/scsi_mod.ko
	    insmod ./kernel/drivers/scsi/scsi_wait_scan.ko
		
	    insmod ./extra/drivers/scsi/sd_mod.ko
		
		insmod ./extra/drivers/usb/usb-common.ko
	    insmod ./extra/drivers/usb/core/usbcore.ko
	    insmod ./extra/drivers/usb/host/hiusb-sd511x.ko
	    insmod ./extra/drivers/usb/host/ehci-hcd.ko
	    insmod ./extra/drivers/usb/host/ehci-pci.ko
	    insmod ./extra/drivers/usb/host/ohci-hcd.ko
	    insmod ./extra/drivers/usb/host/xhci-hcd.ko    
	    insmod ./extra/drivers/usb/storage/usb-storage.ko
	    insmod ./extra/drivers/usb/class/usblp.ko
	    insmod ./extra/drivers/usb/class/cdc-acm.ko
	    insmod ./extra/drivers/usb/serial/usbserial.ko
	    insmod ./extra/drivers/usb/serial/pl2303.ko
	    insmod ./extra/drivers/usb/serial/cp210x.ko
	    insmod ./extra/drivers/usb/serial/ch341.ko
	    insmod ./extra/drivers/usb/serial/ftdi_sio.ko
	    insmod ./extra/drivers/input/input-core.ko
	    insmod ./extra/drivers/hid/hid.ko
	    insmod ./extra/drivers/hid/usbhid/usbhid.ko
	    insmod ./extra/drivers/usb/serial/usbserial.ko
	    insmod ./extra/drivers/usb/serial/usb_wwan.ko
	    insmod ./extra/drivers/usb/serial/option.ko
	    insmod ./extra/drivers/net/usb/hw_cdc_driver.ko
  fi
  if [ -f ./extra/drivers/mmc/core/mmc_core.ko ]; then
	    insmod ./extra/drivers/mmc/core/mmc_core.ko
	    insmod ./extra/drivers/mmc/card/mmc_block.ko
	    insmod ./extra/drivers/mmc/host/himciv100/himci.ko
	    insmod ./extra/drivers/mmc/host/dw_mmc.ko
	    insmod ./extra/drivers/mmc/host/dw_mmc-pltfm.ko
	    insmod ./extra/drivers/mmc/host/dw_mmc-hisi.ko
    fi
    cd /
    
    insmod /lib/modules/wap/hw_module_usb.ko
    insmod /lib/modules/wap/hw_module_datacard.ko
    insmod /lib/modules/wap/hw_module_datacard_chip.ko
    insmod /lib/modules/wap/hw_module_sd.ko
	
    insmod /lib/modules/wap/smp_usb.ko
fi

# AMP_KO
insmod /lib/modules/wap/hw_amp.ko
insmod /lib/modules/wap/hw_module_tty.ko

#

# BBSP_l2_basic
echo "Loading BBSP L2 modules: "
insmod /lib/modules/linux/kernel/drivers/net/slip/slhc.ko
insmod /lib/modules/linux/kernel/drivers/net/ppp/ppp_generic.ko
insmod /lib/modules/linux/kernel/drivers/net/ppp/pppox.ko
insmod /lib/modules/linux/kernel/drivers/net/ppp/pppoe.ko

insmod /lib/modules/wap/commondata.ko
insmod /lib/modules/wap/sfwd.ko
insmod /lib/modules/wap/l2ffwd.ko
insmod /lib/modules/wap/hw_bbsp_lswadp.ko
insmod /lib/modules/wap/hw_ptp.ko
insmod /lib/modules/wap/l2base.ko
insmod /lib/modules/wap/acl.ko
insmod /lib/modules/wap/cpu.ko
insmod /lib/modules/wap/bbsp_l2_adpt.ko
insmod /lib/modules/wap/dbgsoc.ko
# BBSP_l2_basic end


# BBSP_l2_extended
echo "Loading BBSP L2_extended modules: "
insmod /lib/modules/wap/l2ext.ko
# BBSP_l2_extended end

insmod /lib/modules/wap/qos_adpt.ko

# BBSP_l3_basic
echo "Loading BBSP L3_basic modules: "
#insmod /lib/modules/linux/kernel/net/netfilter/nf_conntrack.ko
#insmod /lib/modules/linux/kernel/net/ipv4/netfilter/nf_defrag_ipv4.ko
#insmod /lib/modules/linux/kernel/net/ipv4/netfilter/nf_conntrack_ipv4.ko
#insmod /lib/modules/linux/kernel/net/ipv4/netfilter/nf_nat.ko
#insmod /lib/modules/linux/kernel/net/ipv4/netfilter/iptable_nat.ko
insmod /lib/modules/wap/hw_ssp_gpl_ext.ko

# 依赖hw_ssp_gpl_ext.ko
insmod /lib/modules/wap/hw_module_wifi.ko

#if [ $mem_totalsize -ge 65537 ]
#then
#    echo 8000 > /proc/sys/net/nf_conntrack_max 2>>/var/xcmdlog
#else
#    echo 1500 > /proc/sys/net/nf_conntrack_max 2>>/var/xcmdlog
#fi

#echo 16000 > /proc/sys/net/nf_conntrack_max 2>>/var/xcmdlog
cat /proc/wap_proc/spec | grep -w BBSP_SPEC_FWD_SESSIONNUM | while read spec_name spec_type spec_len spec_value ;do
   if [ $spec_name = "BBSP_SPEC_FWD_SESSIONNUM" ];then
        echo $spec_value | tr -d '\r' | tr -d '\n' > /proc/sys/net/nf_conntrack_max 2>>/var/xcmdlog
   fi
done
echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal 2>>/var/xcmdlog
#add for rtos, to enable connection tracking flow accounting for new kernel
echo 1 > /proc/sys/net/netfilter/nf_conntrack_acct

feature_tde_flag=`GetFeature FT_FEATURE_TDE`
	if [ $feature_tde_flag = 1 ] ;then
		iptables-restore -n < /etc/wap/sec_init_tde
	else
		iptables-restore -n < /etc/wap/sec_init
	fi
	
iptables  -t filter  -I INPUT_DMZIF -p  icmp --icmp-type  13  -j DROP 

insmod /lib/modules/wap/hw_module_trigger.ko
insmod /lib/modules/wap/l3base.ko

#add by zengwei for ip_forward and rp_filter nf_conntrack_tcp_be_liberal
#enable ip forward
echo 1 > /proc/sys/net/ipv4/ip_forward
#disable rp filter
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
#end of add by zengwei for ip_forward and rp_filter nf_conntrack_tcp_be_liberal
# BBSP_l3_basic end

#  load DSP modules
if [ $pots_num -ne 0 ]
then    
    echo "Loading DSP temporary modules: "
    insmod /lib/modules/wap/hw_module_dopra.ko
    insmod /lib/modules/wap/hw_module_dsp_sdk.ko
    insmod /lib/modules/wap/hw_module_dsp.ko
fi
#if file is existed ,don't excute

# BBSP_l3_extended
if [ $l3_ex -eq 0 ]
then    
    echo "NO L3_extended!"
else 
    echo "Loading BBSP L3_extended modules: "
    insmod /lib/modules/linux/kernel/net/ipv4/ip_tunnel.ko
    insmod /lib/modules/linux/kernel/net/ipv4/gre.ko
    insmod /lib/modules/linux/kernel/net/ipv4/ip_gre.ko
    insmod /lib/modules/wap/napt.ko
    insmod /lib/modules/wap/l3ext.ko
    insmod /lib/modules/wap/hw_module_conenat.ko
    insmod /lib/modules/wap/l3sfwd.ko
    insmod /lib/modules/wap/capture.ko
fi
# BBSP_l3_extended end

# BBSP_Ipv6_feature
if [ $ipv6 -eq 0 ]
then    
    echo "NO ipv6!"
else 
    echo "Loading BBSP IPv6 modules: "
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/nf_defrag_ipv6.ko
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/nf_conntrack_ipv6.ko
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/ip6t_rt.ko
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/ip6_tables.ko
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/ip6table_filter.ko
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/ip6table_mangle.ko
	insmod /lib/modules/linux/kernel/net/ipv6/netfilter/ip6t_REJECT.ko	
    insmod /lib/modules/linux/kernel/net/ipv6/netfilter/nf_nat_ipv6.ko
    insmod /lib/modules/linux/kernel/net/ipv6/netfilter/ip6table_nat.ko
	insmod /lib/modules/linux/kernel/net/ipv6/tunnel6.ko
	insmod /lib/modules/linux/kernel/net/ipv6/ip6_tunnel.ko
	insmod /lib/modules/linux/kernel/net/ipv4/tunnel4.ko
	insmod /lib/modules/linux/kernel/net/ipv6/sit.ko
	insmod /lib/modules/wap/wap_ipv6.ko
	insmod /lib/modules/wap/l3sfwd_ipv6.ko
	ip6tables -t mangle -I PREROUTING -m mark --mark 0x102001 -i br+ -j DROP
	ip6tables -A OUTPUT -o ra+ -j DROP
	ip6tables -A OUTPUT -o wl+ -j DROP
	
	feature_tde2=`GetFeature FT_FEATURE_TDE`
        if [ $feature_tde2 = 1 ] ;then
            ip6tables-restore -n < /etc/wap/sec6_init_tde
		else
	    ip6tables-restore -n < /etc/wap/sec6_init
        fi
fi
# BBSP_Ipv6_feature end

# performance start
	#echo "Loading performance monitor modules: "
	#insmod /lib/modules/wap/hw_ssp_performance.ko	
# performance end

# BBSP_hw_route
if [ $hw_route -eq 0 ]
then    
    echo "NO hw_rout!"
else 
    echo "Loading BBSP hw_rout modules: "
    insmod /lib/modules/wap/l3ext.ko
    insmod /lib/modules/wap/wap_ipv6.ko
fi

insmod /lib/modules/wap/bbsp_l3_adpt.ko
insmod /lib/modules/wap/ethoam_adpt.ko
insmod /lib/modules/wap/video_diag_adpt.ko
insmod /lib/modules/wap/btv_adpt.ko

echo "Loading BBSP l2tp modules: "
insmod /lib/modules/linux/kernel/net/l2tp/l2tp_core.ko
insmod /lib/modules/linux/kernel/net/l2tp/l2tp_ppp.ko
echo "Loading netfilter extend connmark modules:"
insmod /lib/modules/wap/hw_module_nf_ext_connmark.ko

template_capture_enable=`GetFeature BBSP_FT_TEMPLATE_CAPTURE`
if [ $template_capture_enable = 1 ]; then
	echo "Loading flow template modules:"
	insmod /lib/modules/wap/hw_module_template.ko
	insmod /lib/modules/wap/hw_flow_template_action.ko
	echo "Loading flow template mirror action modules:"
	insmod /lib/modules/wap/hw_flow_template_action_mirror.ko
	echo "Loading netfilter http modules:"
	insmod /lib/modules/wap/hw_module_xt_http.ko
	insmod /lib/modules/wap/hw_module_xt_capture.ko
fi


if [ -f /lib/modules/wap/mac_filter.ko ]; then  
	insmod /lib/modules/wap/mac_filter.ko
    echo "mac_filter installed ok!"
fi 
# BBSP_IP_FPM
ipfpm_spec=`GetSpec BBSP_SPEC_IP_FPM_STAS_NUM`
if [ $ipfpm_spec -ne 0 ] 
then
    insmod /lib/modules/wap/ipfpm_adpt.ko
    echo "[IP FPM]install ipfpm_adpt.ko OK."
fi
#BBSP_IP_FPM end

#skb内存池
feature_double_wlan=`GetFeature HW_AMP_FEATURE_DOUBLE_WLAN`
feature_11ac=`GetFeature HW_AMP_FEATURE_11AC`
if [ $feature_double_wlan = 1 ] || [ $feature_11ac = 1 ];then
    insmod /lib/modules/wap/skpool.ko
    echo "note:skpool installed!"
fi

#wds特性
feature_wds=`GetFeature HW_AMP_FEATURE_WDS`
if [ $feature_wds = 1 ] ;then
    insmod /lib/modules/wap/wds.ko
    echo "wds installed ok!"
fi

# BBSP_hw_route end

#通过特性开关来启动爱wifi的l2tp_fwd.ko,mark1.ko,FON开启ifb.ko
feature_l2tp=`GetFeature FT_BBSP_AWIFI_SWITCH`
feature_fon=`GetFeature HW_AMP_FEATURE_FON`
if [ $feature_l2tp = 1 ] || [ $feature_fon = 1 ] ;then
    insmod /lib/modules/wap/l2tp_fwd.ko
    insmod /lib/modules/wap/mark1.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_mac.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_REDIRECT.ko
    echo "l2tp mark1 installed ok!"
fi

if [ $feature_fon = 1 ] ;then
    insmod /lib/modules/3.10.53-HULK2/kernel/drivers/net/ifb.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/nfnetlink_cttimeout.ko  	
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/nf_tproxy_core.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_NFQUEUE.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_NFLOG.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_connbytes.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_length.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/net/netfilter/xt_recent.ko		
    echo "ifb installed ok!"
fi

feature_vpn=`GetFeature FT_L2TP_VPN`
if [ $feature_vpn = 1 ];then
    insmod /lib/modules/3.10.53-HULK2/kernel/drivers/net/ppp/pptp.ko
    insmod /lib/modules/3.10.53-HULK2/kernel/drivers/net/ppp/ppp_mppe.ko
    echo "l2tp vpn installed ok!"
fi

if [ $ssid_num -ne 0 ]
then
    insmod /lib/modules/wap/wifi_fwd.ko
fi

while true; do
    if [ -p /var/collect_data_fifo ] ; then
        exec 1>/var/collect_data_fifo
	    break; 
    fi
	sleep 1
done

#绑定pie中断到CPU1
task_bind=3
cpu_plan=`GetSpec SPEC_CPUS_BALANCE_PLAN`
if [ $cpu_plan -eq 1 ] ;then
    echo "Start CPUS BALANCE PLAN ..."
    echo 2 > /proc/irq/132/smp_affinity
    taskset -p 1 1
	task_bind=1
fi
#start for hw_ldsp_cfg进行单板差异化配置，必须放在前面启动
iLoop=0
echo -n "Start ldsp_user..."
if [ -e /bin/hw_ldsp_cfg ]
then
  hw_ldsp_cfg &
  while [ $iLoop -lt 50 ] && [ ! -e /var/hw_ldsp_tmp.txt ] 
  do
    #echo $iLoop
    iLoop=$(( $iLoop + 1 ))
    sleep 0.1
  done
  
  if [ -e /var/hw_ldsp_tmp.txt ]
  then 
      rm -rf /var/hw_ldsp_tmp.txt
  fi
fi

if [ -e /bin/hw_ldsp_xpon_adpt ]
then
    hw_ldsp_xpon_adpt &
fi
#end for hw_ldsp_cfg进行单板差异化配置，必须放在前面启动

#通过特性开关来启动usb_resume进程
resume_enble=`GetFeature HW_SSMP_FEATURE_QUICKCFG`
if [ $resume_enble = 1 ];then
	echo -n "Start usb_resume..."
	taskset $task_bind usb_resume
	break;
fi
iLoop=0
if [ -e /bin/hw_ldsp_cfg ]
then
  while [ $iLoop -lt 100 ] && [ ! -e /var/epon_up_mode.txt ] && [ ! -e /var/gpon_up_mode.txt ] && [ ! -e /var/ge_up_mode.txt ] 
  do
    #echo $iLoop
    iLoop=$(( $iLoop + 1 ))
    sleep 0.1
  done
fi

#打开3.10 R死锁检测softlockup，分配128K大小
echo 128 > /proc/sys/kernel/softlockup_log_size
echo 1 > /proc/sys/kernel/watchdog                
echo 1 500 > /proc/sys/kernel/watchdog_thresh

# install qtn wifi chip driver
cat /proc/bus/pci/devices | cut -f 2 | while read dev_id;
do
	if [ "$dev_id" == "1bb50008" ]; then
		echo "pci device id:$dev_id"
		insmod /lib/modules/wap/qdpc-host.ko
	fi
done


#天翼网关，增加dbus服务启动
if [ $ctrg_support = 1 ]
then
	mkdir -p /var/lib/dbus/
	dbus-uuidgen>>/var/lib/dbus/machine-id &
	mkdir -p /var/run/dbus/

	#挂载后, 先确保 system.conf 存在，再启动dbus-daemon
	if [ ! -f /opt/upt/apps/etc/dbus-1/system.conf ]
	then
	    mkdir -p /opt/upt/apps/etc
	    cp -rf /etc/dbus/dbus-1 /opt/upt/apps/etc/         
	fi

	if [ ! -f /etc/dbus-1/system.conf ]
	then
        echo "Error:not find system.conf"
    else
	    dbus-daemon --system&
	fi

    if [ -f /usr/bin/lxc-create ]
    then
        mkdir -p /var/lib/lxc/
        mkdir -p /var/cache/lxc/
    fi
fi


# start process ---------------------------------------
var_proc_name="ssmp bbsp igmp amp ethoam"

if [ $pots_num -ne 0 ]
then
    var_proc_name=$var_proc_name" voice"
fi

if [ $ssid_num -ne 0 ]
then
    var_proc_name=$var_proc_name" wifi"
fi

if [ -e /var/gpon_up_mode.txt ]
then
    var_proc_name=$var_proc_name" omci"
fi

if [ -e /var/epon_up_mode.txt ]
then
    var_proc_name=$var_proc_name" oam"
fi

en=`cat /var/resume_enble_cwmp`
if [ $en = 1 ];then
#    echo -n "Add cwmp to start..."
    var_proc_name=$var_proc_name" cwmp"
fi

#Feature特性决定ldsp_dect
feature_dect=`GetFeature VOICE_FT_DECT_FEATURE`
if [ $feature_dect -eq 1 ] ;then
    var_proc_name=$var_proc_name" ldsp_dect"
fi

echo $var_proc_name

# start 用于启动时创建共享内存，需要保证进程的个数正确即可，因此omci/oam使用oamomci替代
start $var_proc_name&
echo "Start SSMP..."
su srv_ssmp -c "taskset $task_bind ssmp" &

echo -n "Start BBSP..."
taskset $task_bind bbsp &

echo -n "Start AMP..."
su srv_amp -c "taskset $task_bind amp" & 

echo -n "Start IGMP..."
su srv_igmp -c "taskset $task_bind igmp" &

#echo -n "Start ethoam..."
su srv_ethoam -c "taskset $task_bind ethoam" &

#Feature特性决定ldsp_dect
if [ $feature_dect -eq 1 ] ;then
	su srv_ldsp -c "taskset $task_bind ldsp_dect" & 
fi

#echo -n "Start VOICE ..."
#if file is existed ,don't excute
if [ $pots_num -eq 0 ]
then    
	echo -n "Do not start VOICE..."
else 
    echo -n "Start VOICE ..."
    [ -f /bin/voice_h248 ] && su srv_voice -c "taskset $task_bind voice_h248" &
	[ -f /bin/voice_sip ] && su srv_voice -c "taskset $task_bind voice_sip " &
	[ -f /bin/voice_mgcp ] && su srv_voice -c "taskset $task_bind voice_mgcp " &
	[ -f /bin/voice_h248sip ] && su srv_voice -c "taskset $task_bind voice_h248sip" &
fi

if [ $en = 1 ];then
#    echo -n "Start cwmp..."
    su cfg_cwmp -c "taskset $task_bind cwmp" &
fi

#end first --------------------------------------------

#if [ -e /var/gpon_up_mode.txt ]
#then
#    var_proc_name=$var_proc_name" omci"
#fi
#
#if [ -e /var/epon_up_mode.txt ]
#then
#    var_proc_name=$var_proc_name" oam"
#fi

if [ -e /var/gpon_up_mode.txt ]
then
    #echo -n "Start OMCI..."
    su cfg_omci -c "taskset $task_bind omci" &
fi 

if [ -e /var/epon_up_mode.txt ]
then
    #echo -n "Start OAM..."
    su cfg_oam -c "taskset $task_bind oam" &
fi

if [ $ssid_num -ne 0 ]
then
    echo -n "Start WIFI..."
    su srv_wifi -c "taskset $task_bind wifi" &
fi

#echo -n "Start ProcMonitor..."
while true; do 
    sleep 1
    # 如果ssmploadconfig文件存在，表示消息服务启动成功，可以启动PM进程了
    if [ -f /var/ssmploadconfig ]; then
	    if [ $pots_num -eq 0 ] ; then
	    	echo "Start ProcMonitor without voice ..."

	        taskset $task_bind procmonitor ssmp amp &
            break
	    elif [ -f /bin/voice_h248 ] ; then
	    	echo "Start ProcMonitor with h248 ..."
	        taskset $task_bind procmonitor ssmp amp voice_h248 & break
	    elif [ -f /bin/voice_mgcp ] ; then
	    	echo "Start ProcMonitor with mgcp ..."
	        taskset $task_bind procmonitor ssmp amp voice_mgcp & break
	    elif [ -f /bin/voice_sip ] ; then
	    	 echo "Start ProcMonitor with sip ..."
	        taskset $task_bind procmonitor ssmp amp voice_sip & break
	    elif [ -f /bin/voice_h248sip ] ; then
	    	echo "Start ProcMonitor with h248sip ..."
	   		taskset $task_bind procmonitor ssmp amp voice_h248sip & break     
	  	else
	    	echo "Start ProcMonitor only ..."
	    	taskset $task_bind procmonitor ssmp amp & break
	   	fi
	fi
done &

#iODN产品需要关闭printk打印
printk_enble=`GetFeature HW_SSMP_FEATURE_PRINTK_SILENCE`
if [ $printk_enble == 1 ];then
    echo 0 > /proc/sys/kernel/printk 
fi

while true; do sleep 40 ; taskset $task_bind mu & break; done &

# 延后启动的进程
while true; do sleep 10; 
	if [ -f /var/ssmploaddata ] ; then
		taskset $task_bind apm & break; 
	fi
done &

var_no_osgiproxy_flag=0;
# JVM & OSGi Felix
#OSGI Only for 256M Flash
if [ -c "/dev/ubi0_14" ] && [ $ctrg_support = 0 ]; then
	#added by h00178442 for DTS2015082405628
	chmod 755 /dev
	chmod 655 /dev/urandom
	chmod 655 /dev/random
	#added by h00178442 for DTS2015071306602 DTS2015071303409
	chmod 666 /dev/null;
	
	if [ ! -f /bin/osgi_proxy ];then
		var_no_osgiproxy_flag=1;
	fi
	
	osgiflag=`GetFeature FT_CWMP_WAIT_OSGI`
	echo cmcc is $osgiflag
	if [ $osgiflag = 1 ];then
		while true; do sleep 10; 
			if [ -f /var/ssmploaddata ] ; then
				while [ -f /mnt/jffs2/hw_iotboardtype ] && [ ! -f /mnt/jffs2/hw_iotupdateresult ]
				do  
					sleep 10
				done
				echo osgi_proxy start!
				if [ ! -f /var/kill_java ] ; then
					osgi_proxy & break;
				fi  
			fi
		done &
	else
		while true; 
		do 
			sleep 55; 
			while [ -f /mnt/jffs2/hw_iotboardtype ] && [ ! -f /mnt/jffs2/hw_iotupdateresult ]
			do  
				sleep 10
			done
			
			if [ ! -f /var/kill_java ] ; then
				osgi_proxy & break;
			fi 
			
		done &	
	fi	
    
	if [ ! -d "/mnt/jffs2/app/osgi" ]; then
		mkdir -p /mnt/jffs2/app/osgi;
	fi

    [ -d /mnt/jffs2/osgi ] && rm -rf /mnt/jffs2/osgi
	
    mkdir -p /mnt/jffs2/app;chown osgi_proxy:osgi /mnt/jffs2/app;chmod 750 /mnt/jffs2/app;

	chown -R osgi_proxy:osgi /mnt/jffs2/app/osgi 2>/dev/null;
	chown -R osgi_proxy:osgi /var/osgi 2>/dev/null;
	chown -R osgi_proxy:osgi /var/felix-temp 2>/dev/null;
	chown -R osgi_proxy:osgi /tmp 2>/dev/null; 
	chmod 777 /tmp;
	
    if [ -f /etc/wap/osgi_bundlelist.info ]; then
	    cp -rf /etc/wap/osgi_bundlelist.info /var/osgi/bundlelist.info;
	    chown osgi_proxy:osgi /var/osgi/bundlelist.info;
    fi

	# C plugin
	mkdir -p /mnt/jffs2/app/cplugin;
	if [ -d /mnt/jffs2/cplugin ];then
	    if [ ! -f /mnt/jffs2/app/cplugin/cpluginstate ];then
	        cp -rf /mnt/jffs2/cplugin/* /mnt/jffs2/app/cplugin/
	        rm -rf /mnt/jffs2/cplugin
 	   else
 	       rm -rf /mnt/jffs2/cplugin
 	   fi
	fi

chmod 750 /mnt/jffs2/app/cplugin;
chown osgi_proxy:osgi /mnt/jffs2/app/cplugin;

else
    
#modify for plugin
    chmod a+r /var/wan/dns
    chmod a+x /var/run/dbus
	
appm_not_start=`GetFeature HW_AMP_FEATURE_APPM_NOT_START`
if [ $appm_not_start = 0 ];then
	if [ -e /bin/app_m ];then
		while true; do sleep 10; 
			if [ -f /var/ssmploaddata ] ; then
				su srv_appm -c "taskset $task_bind app_m "& break; 
			fi
		done &
	fi
fi
fi

appm_not_start=`GetFeature HW_AMP_FEATURE_APPM_NOT_START`
if [ $appm_not_start = 0 ];then
	if [ $var_no_osgiproxy_flag = 1 ]; then
		#节省二层启动事件，延时启动app_m
		if [ -e /bin/app_m ];then
			while true; do sleep 10; 
				if [ -f /var/ssmploaddata ] ; then
					su srv_appm -c "taskset $task_bind app_m "& break; 
				fi
			done &
		fi
	fi
fi

#saf-huawei启动由ctrg_m来保证
if [ $ctrg_support = 1  ];then   
    #天翼网关oom策略修改
    #0标识oom时不panic，默认值2
    echo 0 > /proc/sys/vm/panic_on_oom 
    #1标识oom时谁申请杀谁，默认值0
    echo 1 > /proc/sys/vm/oom_kill_allocating_task
fi

#启动ctrg_m服务进程
count=0
if [ -e /bin/ctrg_m ];then
	while true; 
	do
		if [ ! -f /mnt/jffs2/customizepara.txt ] && [ ! -f /mnt/jffs2/Equip.sh ]
		then			
			sleep 60; 
		else
			sleep 10; 
		fi
		
		if  [ -f /var/tianyi_stop ]
		then
			break;
		fi
		
		if [ -f /var/ssmploaddata ] ; then
			if [  $ssid_num -eq 0 ] || [ -f /var/webwlanstartflag ] || [ $count -gt 6 ]; then
				echo "ctrg_m started"
				taskset $task_bind ctrg_m & break; 
			else	
				count=`expr $count + 1`
			fi
		fi
	done &
fi

#insmod y1731 ko for 5115S/H
var_soc_attr=`GetChipDes`
var_soc_type=`echo $var_soc_attr | sed 's/.*\"SD//'| sed 's/V[0-9]*\"//' | tr -d '[\015]'`
echo "current soc is $var_soc_type"
feature_1731_enble=`GetFeature BBSP_FT_1731`
if [ $feature_1731_enble = 1 ];then
	if [ "${var_soc_type:0:5}" == "5115S" ] || [ "${var_soc_type:0:5}" == "5115H" ] ; then
		insmod /lib/modules/hisi_sdk/hi_kit.ko
		echo "hi_kit installed ok!"
	fi
fi

#insmod p2p nac ko
feature_p2p_nac=`GetFeature BBSP_FT_P2P_NAC`
if [ $feature_p2p_nac = 1 ]; then
	if [ -f /lib/modules/wap/nac.ko ]; then
		insmod /lib/modules/wap/nac.ko
	fi
fi

#通过特性开关来启动usb_mngt进程
usb_enble=`GetFeature HW_SSMP_FEATURE_USB`
usbsmart_enble=`GetFeature HW_SSMP_FEATURE_USBSMART`
if [ $usb_enble = 1 ] || [ $usbsmart_enble = 1 ];then
	while true;
	do
		sleep 20
		echo -n "Start usb_mngt..."
#		su srv_usb -c "taskset $task_bind usb_mngt" & break;
		taskset $task_bind usb_mngt & break;
	done &
fi 


while true; do
    sleep 10
    if [ -f /var/ssmploaddata ] ; then
        taskset $task_bind ldspcli & break; 
    fi
done &

#延时20秒，保证可以取得正确feature，从而保证WEB进程启动正常
sleep 20

#通过特性开关来启动WEB进程
sleep_count=0
resume_enble=`GetFeature HW_SSMP_FEATURE_WEB`
if [ $resume_enble = 1 ];then
	while true; do sleep 10; 
		if [ -f /var/ssmploaddata ] ; then
			if [  $ssid_num -eq 0 ] ||  [ -f /var/webwlanstartflag ]  || [ $sleep_count -gt 6 ]; then
				su srv_web -c "taskset $task_bind web "& break; 
			else
				sleep_count=`expr $sleep_count + 1`
			fi
		fi
	done &
fi

#节省二层启动事件，延时启动iaccess  HW_SSMP_FEATURE_GXBMONITOR
while true; do sleep 10; 
	if [ -f /var/ssmploaddata ] ; then
		iaccess_enble=`GetFeature HW_SSMP_FEATURE_GXBMONITOR`
		if [ -e /bin/iaccess ] && [ $iaccess_enble = 1 ];then
			su srv_ssmp -c "taskset $task_bind iaccess" & break; 
		else
			break;
		fi
	fi
done &

UpnpEnable=0
if [ $ssid_num -ne 0 ] && [ -e /bin/udm ] ; then
    var_pack_temp_dir=/bin
    var_hw_ctree_udm=/var/hw_ctree_udm.xml
    cp -rf /mnt/jffs2/hw_ctree.xml $var_hw_ctree_udm -f
    $var_pack_temp_dir/aescrypt2 1 $var_hw_ctree_udm $var_hw_ctree_udm"_tmp"
    if [ 0 -eq $? ] 
	then
		mv $var_hw_ctree_udm $var_hw_ctree_udm".gz" -f
		gunzip -f $var_hw_ctree_udm".gz"
	fi  
	
    rm -rf /var/cfgtool_ret
		UpnpEnable=1
		var_wificover_path="InternetGatewayDevice.X_HW_WifiCoverService"
		cfgtool gettofile $var_hw_ctree_udm $var_wificover_path Enable
		if [ 0 -eq $? ] ; then
			if [ -f "/var/cfgtool_ret" ] ; then
				read UpnpEnable < /var/cfgtool_ret
			fi
		fi
	    echo "UpnpEnable="$UpnpEnable
    rm -f $var_hw_ctree_udm
    
    while true; do sleep 10; 
		if [ -f /var/ssmploaddata ] && [ $UpnpEnable = 1 ] ; then
			taskset $task_bind udm & break; 
		fi
	done &
fi

feature_awifi=`GetFeature HW_AMP_FT_FEATURE_AWIFI`
if [ $feature_awifi -eq 1 ] ;then
	while true; do sleep 10;
		if [ -f /var/ssmploaddata ] ; then
			taskset $task_bind awifi & break;  
		fi
	done &
fi

if [ $feature_fon -eq 1 ] ;then
	while true; do sleep 10;
		if [ -f /var/ssmploaddata ] ; then
			taskset $task_bind fon & break; 
		fi
	done &
fi

#删除恢复出厂设置的标示文件
rm -f /mnt/jffs2/factory_reset_tag

#启动完成之后，恢复打印级别为4
if [ $printk_enble -ne 1 ];then
    echo 4 > /proc/sys/kernel/printk 
fi

# After system up, drop the page cache.
while true; do sleep 10 ; 
	if [ -f /var/ssmploaddata ] ; then
		 sleep 15 
		 echo $MIN_FREE_INFO > /proc/sys/vm/min_free_kbytes
	#     echo 3 > /proc/sys/vm/drop_caches
		 kill -9 `ps | grep "sh -c taskset $task_bind" | grep  -v grep | awk '{print $1}'`
		 write_proc /proc/sys/vm/drop_caches 3
		 echo "Dropped the page cache. Limit is $MIN_FREE_INFO"; 
		 if [ -f /var/lastsysinfo.tar.gz ] ; then 
			mv -f /var/lastsysinfo.tar.gz /mnt/jffs2/lastsysinfo.tar.gz
		 fi
		 break; 
	 fi
done &

while true; do sleep 10;
	if [ -f /var/ssmploaddata ] ; then
		e8c_qoe_enble=`GetFeature FT_E8C_QOE`
		if [ $qoe_enble = 1 ] || [ $e8c_qoe_enble = 1 ];then
			taskset $task_bind qoe & break; 
		else
			break;
		fi
	fi
done &


audit_obj_enble=`GetFeature FT_CWMP_NODE_AUDIT_PLUGIN`
if [ $audit_obj_enble = 1 ];then
	while true; do sleep 10;
		if [ -f /var/ssmploaddata ] ; then
			taskset $task_bind audit & break; 
		fi
	done &
fi

#echo 200 > /proc/sys/vm/lowmem_reserve_ratio

