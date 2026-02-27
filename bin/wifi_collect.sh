#! /bin/sh

export wifi_collect_flag=0;

RunCmd()
{
	echo "$* :"
	$*
}
CollectRT5392()
{
	RunCmd ifconfig -a
	
	RunCmd cat /var/RT2860AP.dat | grep -v [kK]ey | grep -v P[sS][kK][0-9] | grep -v Pin
				
	RunCmd cat /proc/wifilog/channel/2G
				
	RunCmd cat /proc/wifilog/connect/2G
				
	RunCmd cat /proc/wifilog/config/2G
	
	RunCmd cat /proc/wifilog/cmdout/2G
	
	rt_devlist="ra0 ra1 ra2 ra3"
	
	for rt_dev in $rt_devlist
	do
		
		RunCmd iwpriv $rt_dev stat | grep -v Pin
		
		RunCmd iwpriv $rt_dev rf

		RunCmd iwpriv $rt_dev e2p
		
		echo "clearlog 2G "> /proc/wifilog/cmdout/All
		
		echo "iwpriv $rt_dev show stainfo:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show stainfo
		
		echo "iwpriv $rt_dev show stacountinfo:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show stacountinfo
		
		echo "iwpriv $rt_dev show stasecinfo:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show stasecinfo
		
		echo "iwpriv $rt_dev show bainfo:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show bainfo
		
		echo "iwpriv $rt_dev show TxRate:" >/proc/wifilog/cmdout/2G		
		iwpriv $rt_dev  show TxRate
		
		echo "iwpriv $rt_dev show FalseCCA:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show FalseCCA
		
		echo "iwpriv $rt_dev show CN:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show CN
		
		echo "iwpriv $rt_dev show UnicastRate:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show UnicastRate
		
		echo "iwpriv $rt_dev show Chanspec:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show Chanspec
		
		echo "iwpriv $rt_dev show Rssi:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show Rssi
		
		echo "iwpriv $rt_dev show FilterMac:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show FilterMac
		
		echo "iwpriv $rt_dev show FilterMacMode:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show FilterMacMode
		
		echo "iwpriv $rt_dev show peerinfo=$rt_dev:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show peerinfo=$rt_dev
		
		echo "iwpriv $rt_dev show FrameBurst:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show FrameBurst
		
		echo "iwpriv $rt_dev show BandWidth:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show BandWidth
		
		echo "iwpriv $rt_dev show pwrinfo:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show pwrinfo
		
		echo "iwpriv $rt_dev show rateset:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show rateset
		
		echo "iwpriv $rt_dev show chanlist:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show chanlist
		
		echo "iwpriv $rt_dev show pwrpercent:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show pwrpercent
		
		echo "iwpriv $rt_dev show txwme:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show txwme
		
		echo "iwpriv $rt_dev show commonconfig:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show commonconfig
		
		echo "iwpriv $rt_dev show interfaceconfig:" >/proc/wifilog/cmdout/2G
		iwpriv $rt_dev show interfaceconfig
		
		cat /proc/wifilog/cmdout/2G
		echo "clearlog 2G "> /proc/wifilog/cmdout/All
		
		RunCmd iwconfig $rt_dev
	done
}

CollectMT7603()
{
	RunCmd ifconfig -a
	
	RunCmd cat /var/RT2860AP_7603.dat | grep -v [kK]ey | grep -v P[sS][kK][0-9] | grep -v Pin
				
	RunCmd cat /proc/wifilog/channel/2G
				
	RunCmd cat /proc/wifilog/connect/2G
				
	RunCmd cat /proc/wifilog/config/2G
	
	RunCmd cat /proc/wifilog/cmdout/2G
	
	mt7603_devlist="ra0 ra1 ra2 ra3"
	
	for mt_dev in $mt7603_devlist
	do
		RunCmd iwpriv $mt_dev stat | grep -v Pin

		RunCmd iwpriv $mt_dev e2p
		
		echo "clearlog 2G "> /proc/wifilog/cmdout/All
		
		echo "iwpriv $mt_dev show stainfo:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show stainfo
		
		echo "iwpriv $mt_dev show stacountinfo:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show stacountinfo
		
		echo "iwpriv $mt_dev show stasecinfo:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show stasecinfo
		
		echo "iwpriv $mt_dev show bainfo:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show bainfo
		
		echo "iwpriv $mt_dev show TxRate:" >/proc/wifilog/cmdout/2G		
		iwpriv $mt_dev show TxRate
		
		echo "iwpriv $mt_dev show FalseCCA:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show FalseCCA
		
		echo "iwpriv $mt_dev show CN:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show CN
		
		echo "iwpriv $mt_dev show UnicastRate:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show UnicastRate
		
		echo "iwpriv $mt_dev show Chanspec:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show Chanspec
		
		echo "iwpriv $mt_dev show Rssi:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show Rssi
		
		echo "iwpriv $mt_dev show Assolist:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show Assolist
		
		echo "iwpriv $mt_dev show FilterMacMode:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show FilterMacMode
		
		echo "iwpriv $mt_dev show peerinfo=$mt_dev:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show peerinfo=$mt_dev
		
		echo "iwpriv $mt_dev show FrameBurst:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show FrameBurst
		
		echo "iwpriv $mt_dev show BandWidth:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show BandWidth
		
		echo "iwpriv $mt_dev show pwrinfo:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show pwrinfo
		
		echo "iwpriv $mt_dev show rateset:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show rateset
		
		echo "iwpriv $mt_dev show chanlist:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show chanlist
		
		echo "iwpriv $mt_dev show pwrpercent:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show pwrpercent
		
		echo "iwpriv $mt_dev show txwme:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show txwme
		
		echo "iwpriv $mt_dev show commonconfig:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show commonconfig
		
		echo "iwpriv $mt_dev show interfaceconfig:" >/proc/wifilog/cmdout/2G
		iwpriv $mt_dev show interfaceconfig
		
		cat /proc/wifilog/cmdout/2G
		echo "clearlog 2G "> /proc/wifilog/cmdout/All
		
		RunCmd iwconfig $mt_dev
	done
}

CollectMT7612()
{
	RunCmd cat /var/RT2860AP_7612.dat | grep -v [kK]ey | grep -v P[sS][kK][0-9] | grep -v Pin
				
	RunCmd cat /proc/wifilog/channel/5G
				
	RunCmd cat /proc/wifilog/connect/5G
				
	RunCmd cat /proc/wifilog/config/5G
	
	RunCmd cat /proc/wifilog/cmdout/5G
	
	mt7612_devlist="rai0 rai1 rai2 rai3"
	
	for dev in $mt7612_devlist
	do
		RunCmd iwpriv $dev stat | grep -v Pin
		
		RunCmd iwpriv $dev rf
		
		RunCmd iwpriv $dev e2p
		
		echo "clearlog 5G "> /proc/wifilog/cmdout/All
		
		echo "iwpriv $dev show stainfo:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show stainfo
		
		echo "iwpriv $dev show stacountinfo:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show stacountinfo
		
		echo "iwpriv $dev show stasecinfo:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show stasecinfo
		
		echo "iwpriv $dev show bainfo:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show bainfo
		
		echo "iwpriv $dev  show TxRate:" >/proc/wifilog/cmdout/5G		
		iwpriv $dev show TxRate
		
		echo "iwpriv $dev show FalseCCA:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show FalseCCA
		
		echo "iwpriv $dev show CN:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show CN
		
		echo "iwpriv $dev show UnicastRate:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show UnicastRate
		
		echo "iwpriv $dev show Chanspec:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show Chanspec
		
		echo "iwpriv $dev show Rssi:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show Rssi
		
		echo "iwpriv $dev show FilterMac:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show FilterMac
		
		echo "iwpriv $dev show FilterMacMode:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show FilterMacMode
		
		echo "iwpriv $dev show peerinfo=$dev:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show peerinfo=$dev
		
		echo "iwpriv $dev show FrameBurst:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show FrameBurst
		
		echo "iwpriv $dev show BandWidth:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show BandWidth
		
		echo "iwpriv $dev show pwrinfo:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show pwrinfo
		
		echo "iwpriv $dev show rateset:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show rateset
		
		echo "iwpriv $dev show chanlist:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show chanlist
		
		echo "iwpriv $dev show pwrpercent:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show pwrpercent
		
		echo "iwpriv $dev show txwme:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show txwme
		
		echo "iwpriv $dev show commonconfig:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show commonconfig
		
		echo "iwpriv $dev show interfaceconfig:" >/proc/wifilog/cmdout/5G
		iwpriv $dev show interfaceconfig
		
		cat /proc/wifilog/cmdout/5G
		echo "clearlog 5G "> /proc/wifilog/cmdout/All
		
		RunCmd iwconfig $dev
	done
}

CollectBCM2G()
{
	RunCmd ifconfig -a

	RunCmd cat /var/wifi.txt | grep -v psk | grep -v key | grep -v "_pin=" | grep -v "PIN"
	
	RunCmd wl -i wl0 country

	RunCmd wl -i wl0 chanspec
	
	RunCmd wl -i wl0 curpower

	RunCmd wl -i wl0 frameburst
	
	RunCmd wl -i wl0 interference
	
	RunCmd wl -i wl0 dump rssi
	
	RunCmd wl -i wl0 phy_rssi_ant
	
	RunCmd wl -i wl0 counters
	
	RunCmd wl -i wl0 dump ampdu
	
	RunCmd wl -i wl0 wme_counters
	
	RunCmd wl -i wl0 pktq_stats
	
	RunCmd wl -i wl0 chanim_stats
	
	RunCmd wl -i wl0 phy_ed_thresh
	
	RunCmd wl -i wl0 nvram_dum
	
	RunCmd wl -i wl0 revinfo
	
	RunCmd wl -i wl0 cur_mcsset
	
	RunCmd wl -i wl0 wme_tx_params
	
	RunCmd wl -i wl0 chan_info
	
	RunCmd wl -i wl0 curpower
	
	bcm43217_devlist="wl0 wl0.1 wl0.2 wl0.3"
	
	for dev in $bcm43217_devlist
	do
		RunCmd wl -i $dev rate
		
		RunCmd wl -i $dev nrate
		
		RunCmd wl -i $dev mrate
		
		RunCmd wl -i $dev assoc
		
		RunCmd wl -i $dev assoclist
		
		RunCmd wl -i $dev interference_override
		
		RunCmd wl -i $dev wme_ac ap
		
		RunCmd wl -i $dev wme_ac sta
		
		stamac=`wl -i $dev assoclist`
		
		echo "wl -i $dev sta_info "
		
		if [ ! -n "$stamac" ]; then
			
			echo "NULL"
			
		else
		
			stamac=`echo $stamac | tr -d 'assoclist'`
			
			for sta in $stamac
			do
				wl -i $dev sta_info $sta
				
			done
        fi 
		
	done

	if [ `cat /proc/bus/pci/devices | cut -f 2 | wc -l` -eq 1 ];then
	
		RunCmd wl -i wl0.4 assoc
		
		RunCmd wl -i wl0.5 assoc
		
		RunCmd wl -i wl0.6 assoc
		
		RunCmd wl -i wl0.7 assoc
				
		RunCmd wl phyreg 0x283

		RunCmd wl phyreg 0x280

		RunCmd wl phyreg 0x289
		

	fi
				
	RunCmd cat /proc/wifilog/channel/2G
				
	RunCmd cat /proc/wifilog/connect/2G
				
	RunCmd cat /proc/wifilog/config/2G
	
	RunCmd cat /proc/wifilog/cmdout/2G
	

}

CollectBCM5G()
{
	RunCmd wl -i wl1 country

	RunCmd wl -i wl1 chanspec
	
	RunCmd wl -i wl1 curpower

	RunCmd wl -i wl1 frameburst
	
	RunCmd wl -i wl1 interference
	
	RunCmd wl -i wl1 dump rssi
	
	RunCmd wl -i wl1 phy_rssi_ant
	
	RunCmd wl -i wl1 counters
	
	RunCmd wl -i wl1 dump ampdu
	
	RunCmd wl -i wl1 wme_counters
	
	RunCmd wl -i wl1 pktq_stats
	
	RunCmd wl -i wl1 chanim_stats
	
	RunCmd wl -i wl1 phy_ed_thresh
	
	RunCmd wl -i wl1 nvram_dum
	
	RunCmd wl -i wl1 revinfo
	
	RunCmd wl -i wl1 cur_mcsset
	
	RunCmd wl -i wl1 wme_tx_params
	
	RunCmd wl -i wl1 chan_info
	
	RunCmd wl -i wl1 curpower

	bcm4360_devlist="wl1 wl1.1 wl1.2 wl1.3"
	
	for dev in $bcm4360_devlist
	do
		RunCmd wl -i $dev rate
		
		RunCmd wl -i $dev nrate
		
		RunCmd wl -i $dev mrate
		
		RunCmd wl -i $dev assoc
		
		RunCmd wl -i $dev assoclist
		
		RunCmd wl -i $dev interference_override
		
		RunCmd wl -i $dev wme_ac ap
		
		RunCmd wl -i $dev wme_ac sta
		
		stamac=`wl -i $dev assoclist`
		
		echo "wl -i $dev sta_info "
		
		if [ ! -n "$stamac" ]; then
			
			echo "NULL"
			
		else
		
			stamac=`echo $stamac | tr -d 'assoclist'`
			
			for sta in $stamac
			do
				wl -i $dev sta_info $sta
				
			done
        fi 
		
	done

				
	RunCmd cat /proc/wifilog/channel/5G
				
	RunCmd cat /proc/wifilog/connect/5G
				
	RunCmd cat /proc/wifilog/config/5G
	
	RunCmd cat /proc/wifilog/cmdout/5G
}

ProtectDmesgExe()
{
	dmesg > /var/tmplog1.txt
	
    RunCmd $*
	
    dmesg > /var/tmplog2.txt
	
    line=`cat /var/tmplog1.txt|wc -l`

    awk -v va=$line 'NR > va {print i} {i=$0}' /var/tmplog2.txt
	
	rm /var/tmplog1.txt
	
	rm /var/tmplog2.txt
}

CollectRTL8192()
{
	rtl_devlist="wlan0 wlan0-va0 wlan0-va1 wlan0-va2 wlan0-va3 wlan0-va4 wlan0-va5 wlan0-va6"
	
	RunCmd ifconfig -a

	# root ap info
	echo ""
	echo "[wlan0.mib_rf]: "
	cat /proc/wlan0/mib_rf
	
	ProtectDmesgExe iwpriv wlan0 reg_dump
	
	echo "[wifi  log]: "
	cat /proc/wifilog/log
	# ssid info
	for rtl_dev in $rtl_devlist; do
		if [ -d /proc/$rtl_dev ]; then
			
			echo ""
			echo "[$rtl_dev.sta_info]: "
			cat /proc/$rtl_dev/sta_info
			
			echo ""
			echo "[$rtl_dev.sta_dbginfo]: "
			cat /proc/$rtl_dev/sta_dbginfo
			
			echo ""
			echo "[$rtl_dev.mib_operation]: "
			cat /proc/$rtl_dev/mib_operation

			echo ""
			echo "[$rtl_dev.stats]: "
			cat /proc/$rtl_dev/stats
			
			echo ""
			echo "[$rtl_dev.mib_all]: "
			cat /proc/$rtl_dev/mib_all
		fi
	done
}

CollectQSR1000()
{
	#add route
	ip route add 192.168.176.0/24 dev host0
	
	(
	sleep 0.1
	echo 'root'
	sleep 0.1
	echo 'gather_info'
	sleep 65
	echo 'exit'
	) | telnet 192.168.176.176
	
	#delete route
	ip route del 192.168.176.0/24 dev host0
	
	echo "QSR1000 is being finished!"
	echo "---------------------------------------"
}

CollectQCA()
{
	QCA_devlist="ath0 ath1 ath2 ath3 ath4 ath5 ath6 ath7"
	
	if [ $wifi_collect_flag -ne 0 ];then
		return;
	fi
	
	wifi_collect_flag=1;
	
	for dev in $QCA_devlist
	do
		ifconfig $dev | grep UP
		if [ $? -eq 0 ];then
			if [ $dev == ath0 ];then
				
				RunCmd iwpriv $dev get_countrycode
				
				RunCmd iwlist $dev ch
				
				RunCmd wlanconfig $dev list channel

				RunCmd iwpriv $dev get_mode
				
				RunCmd iwpriv $dev get_pureg
				
				RunCmd iwpriv $dev get_puren
				
				RunCmd iwlist $dev txpower
				
				RunCmd cat /proc/wifilog/channel/2G
				
				RunCmd cat /proc/wifilog/connect/2G
				
				RunCmd cat /proc/wifilog/config/2G	
				
				RunCmd athstats -i wifi1
				
				RunCmd iwpriv wifi1 get_burst
				
				RunCmd iwpriv wifi1 get_burst_dur

			fi

			if [ $dev == ath4 ];then
				
				RunCmd iwpriv $dev get_countrycode
				
				RunCmd iwlist $dev ch
				
				RunCmd wlanconfig $dev list channel

				RunCmd iwpriv $dev get_mode
				
				RunCmd iwpriv $dev get_pureg
				
				RunCmd iwpriv $dev get_puren
				
				RunCmd iwlist $dev txpower
				
				RunCmd cat /proc/wifilog/channel/5G
				
				RunCmd cat /proc/wifilog/connect/5G
				
				RunCmd cat /proc/wifilog/config/5G
				
				RunCmd athstats -i wifi0
				
				RunCmd iwpriv wifi0 get_burst
				
				RunCmd iwpriv wifi0 get_burst_dur
	
			fi
			
			if [ $dev == ath4 ]||[ $dev == ath5 ]||[ $dev == ath6 ]||[ $dev == ath7 ];then
							
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 1
				
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 2				

				ProtectDmesgExe iwpriv $dev txrx_fw_stats 3
								
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 4
								
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 5
				
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 6
							
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 7
						
				ProtectDmesgExe iwpriv $dev txrx_fw_stats 8	
			
			fi
			
			RunCmd cat /var/hostapd-$dev.conf | grep -v psk | grep -v key | grep -v "_pin=" | grep -v "PIN" | grep -v "passphrase" | grep -v "secret" | grep -v "uuid"
			
			RunCmd iwconfig $dev
			
			RunCmd iwpriv $dev get_shortgi
		
			RunCmd iwpriv $dev get_wmm
		
			RunCmd wlanconfig $dev list sta
			
			RunCmd iwpriv $dev get_maccmd
			
			RunCmd iwpriv $dev getmac
			
			RunCmd iwpriv $dev medump
			
			RunCmd apstats -R -v -i $dev
		fi
	done
}

# exe script according to wifi chip type
ExeCollectCmd()
{
	# $1 = wifi_id

	case $1 in
	
	#ralink
	18143091 | 18145390 | 18145392 )
		CollectRT5392
		;;
		
	#mt7603
	14c37603 )
		CollectMT7603
		;;
		
	#mt7612
	14c37662 )
		CollectMT7612
		;;
		
	#bcm43217
	14e443a9 | 14e4a8db )
		CollectBCM2G
		;;

	#bcm4331
	14e44331 )
		CollectBCM2G
		;;

	#bcm4360
	14e44360 )
		CollectBCM5G
		;;

	#rtl8192
	10ec818b )
		CollectRTL8192
		;;
		
	#QSR1000 
	1bb50008 )
		CollectQSR1000
		;;

	#AR9381/QCA9880/QCA9984
	168c0030 | 168c003c | 168c0046)
		CollectQCA
		;;
	* )
		;;
	esac

}

# read pci device id
cat /proc/bus/pci/devices | cut -f 2 | while read dev_id;
do
	if [ "$dev_id" != "" ]; then
	echo "pci device id:$dev_id"
	ExeCollectCmd $dev_id
	fi
done

