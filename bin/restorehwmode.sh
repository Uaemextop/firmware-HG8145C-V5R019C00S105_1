#! /bin/sh

#set hw parameters
#copy etc/wap/hw_default_ctree.xml to /mnt/jffs2/hw_ctree.xml
#set the spec para

var_default_ctree=/mnt/jffs2/hw_default_ctree.xml;
var_ctree=/mnt/jffs2/hw_ctree.xml
var_customize=/mnt/jffs2/customizepara.txt
var_bms_prevxml_temp="/mnt/jffs2/hw_bms_prev.xml"
var_bms_oldcrc_temp="/mnt/jffs2/oldcrc"
var_bms_oltoldcrc_temp="/mnt/jffs2/oltoldcrc"
var_bms_prevcrc_temp="/mnt/jffs2/prevcrc"
var_bms_oltprevcrc_temp="/mnt/jffs2/oltprevcrc"
var_bms_oskvoice_temp="/mnt/jffs2/hw_osk_voip_prev.xml"
var_rebootsave="/mnt/jffs2/cwmp_rebootsave"
var_recovername_temp="/mnt/jffs2/recovername"
var_usr_device_temp="/mnt/jffs2/usr_device.bin"
var_ftcrc_temp="/mnt/jffs2/FTCRC"
var_ftvoip_temp="/mnt/jffs2/ftvoipcfgstate"
var_dhcp_temp="/mnt/jffs2/dhcpc"
var_dhcp6_temp="/mnt/jffs2/dhcp6c"
var_DHCPlasterrwan1_temp="/mnt/jffs2/DHCPlasterrwan1"
var_DHCPlasterrwan2_temp="/mnt/jffs2/DHCPlasterrwan2"
var_DHCPlasterrwan3_temp="/mnt/jffs2/DHCPlasterrwan3"
var_DHCPlasterrwan4_temp="/mnt/jffs2/DHCPlasterrwan4"
var_DHCPstatewan1_temp="/mnt/jffs2/DHCPstatewan1"
var_DHCPstatewan2_temp="/mnt/jffs2/DHCPstatewan2"
var_DHCPstatewan3_temp="/mnt/jffs2/DHCPstatewan3"
var_DHCPstatewan4_temp="/mnt/jffs2/DHCPstatewan4"
var_DHCPoutputwan1_temp="/mnt/jffs2/DHCPoutputwan1"
var_boardinfo_file="/mnt/jffs2/hw_boardinfo"
var_boardinfo_bakfile="/mnt/jffs2/hw_boardinfo.bak"
var_boardinfo_temp="/mnt/jffs2/hw_boardinfo.temp"
var_jffs2_customize_txt_file="/mnt/jffs2/customize.txt"
var_jffs2_choose_xml_dir="/mnt/jffs2/choose_xml"
var_jffs2_choose_xml_tar="/mnt/jffs2/choose_xml.tar.gz"
var_jffs2_spec_file="/mnt/jffs2/hw_hardinfo_spec"
var_jffs2_spec_bak_file="/mnt/jffs2/hw_hardinfo_spec.bak"
var_jffs2_feature_file="/mnt/jffs2/hw_hardinfo_feature"
var_jffs2_feature_bak_file="/mnt/jffs2/hw_hardinfo_feature.bak"
var_jffs2_hardinfo_para_file="/mnt/jffs2/hw_equip_hardinfo"
var_ontfirstonline_temp="/mnt/jffs2/ontfirstonlinefile"
var_dublecore="/mnt/jffs2/doublecore"
var_customize_telmex=/mnt/jffs2/TelmexCusomizePara
var_customize_dir="/mnt/jffs2/customize"
var_smartshowbssguide="/mnt/jffs2/smartshowbssguide"
var_smartshowuserguide="/mnt/jffs2/smartshowuserguide"
var_old_ctree="/mnt/jffs2/hw_old_ctree.xml"
var_ctree_bak="/mnt/jffs2/hw_ctree_bak.xml"
var_cfgbackup="/mnt/jffs2/CfgFile_Backup"
var_PrimaryDir="/mnt/jffs2/PrimaryDir"
var_p2p_dhcp_file="/mnt/jffs2/p2pdhcpboot_prev.ini"
var_jffs2_hardversion_bak_file="/mnt/jffs2/hw_boardinfo.bak"
var_jffs2_specsn_file="/mnt/jffs2/customize_specsn"

var_plat_root="/mnt/jffs2/platroot.crt" 
var_plat_pub="/mnt/jffs2/platpub.crt"
var_plat_prvt="/mnt/jffs2/platprvt.key"

# remove plugin files 
HW_Script_RemovePluginFile()
{
	#通过特性开关来决定删除哪些插件
	var_feature_enble=`GetFeature HW_FT_OSGI_JVM_FROM_VAR`
	if [ $var_feature_enble = 1 ];then
		rm  -rf /mnt/jffs2/app/osgi/felix-cache;
        rm  -f /mnt/jffs2/app/osgi/prebundlestatus.info;
        rm  -f /mnt/jffs2/app/osgi/dlna.jar;
        rm  -f /mnt/jffs2/app/osgi/samba.jar;
	else
		rm  -rf /mnt/jffs2/app/osgi/* ;
	fi
	rm -rf  /mnt/jffs2/app/cplugin/* /var/cplugin/*;
}

# remove files
HW_Script_RemoveFile()
{
	rm -f $var_default_ctree
	rm -f $var_ctree
	rm -f $var_customize
	rm -f $var_bms_prevxml_temp
	rm -f $var_bms_oldcrc_temp
	rm -f $var_bms_oltoldcrc_temp
	rm -f $var_bms_prevcrc_temp
	rm -f $var_bms_oltprevcrc_temp
	rm -f $var_bms_oskvoice_temp
	rm -f $var_rebootsave
	rm -f $var_recovername_temp
	rm -f $var_usr_device_temp
	rm -rf $var_ftcrc_temp
	rm -rf $var_ftvoip_temp
	rm -rf $var_dhcp_temp
	rm -rf $var_dhcp6_temp
	rm -rf $var_DHCPlasterrwan1_temp
	rm -rf $var_DHCPlasterrwan2_temp
	rm -rf $var_DHCPlasterrwan3_temp
	rm -rf $var_DHCPlasterrwan4_temp
	rm -rf $var_DHCPstatewan1_temp
	rm -rf $var_DHCPstatewan2_temp
	rm -rf $var_DHCPstatewan3_temp
	rm -rf $var_DHCPstatewan4_temp
	rm -rf $var_DHCPoutputwan1_temp
	rm -rf $var_jffs2_customize_txt_file
	rm -rf $var_jffs2_choose_xml_dir
	rm -f $var_jffs2_choose_xml_tar
	rm -fr $var_jffs2_spec_file
	rm -fr $var_jffs2_spec_bak_file
	rm -fr $var_jffs2_feature_file
	rm -fr $var_jffs2_feature_bak_file
	rm -fr $var_jffs2_hardinfo_para_file
	rm -fr $var_ontfirstonline_temp
	rm -f $var_dublecore
	rm -f /mnt/jffs2/simcard_flowflag
	rm -f /mnt/jffs2/simcardreadflag
	rm -f /mnt/jffs2/typeword
	rm -f $var_customize_telmex
	rm -rf $var_customize_dir
	rm -f $var_smartshowbssguide
	rm -rf $var_smartshowuserguide
	rm -fr $var_old_ctree
	rm -fr $var_ctree_bak
	rm -fr $var_cfgbackup
	rm -f $var_jffs2_hardversion_bak_file
	rm -rf $var_PrimaryDir
	rm -rf /mnt/jffs2/p2ploadcfgdone
	rm -rf /mnt/jffs2/dhcp6c
    rm -rf /mnt/jffs2/dhcpc
	rm -rf /mnt/jffs2/onlinecounter
	rm -rf $var_jffs2_specsn_file
	rm -rf /mnt/jffs2/reboot_bind_tag
	rm -rf $var_p2p_dhcp_file
		
	rm  -rf /mnt/jffs2/app/osgi/*
	rm  -rf /mnt/jffs2/app/cplugin/*
	
	rm -f /mnt/jffs2/smooth_finsh
	rm -f /mnt/jffs2/exstbmac.bin
	rm -f /mnt/jffs2/stbmac.bin
	rm -f /var/new_key_encryte_ctree
	
	if [ -f /mnt/jffs2/Install_gram/control_audit.sh ] ; then
		/mnt/jffs2/Install_gram/control_audit.sh --stop >/dev/null 2>&1 
		rm -rf /mnt/jffs2/Install_gram
	fi
	
	if [ -f /mnt/jffs2/Probe/probe ] ; then
		rm -rf /mnt/jffs2/Probe
	fi
	
	rm -f $var_plat_root
	rm -f $var_plat_pub
	rm -f $var_plat_prvt
	rm -rf /mnt/jffs2/stagingmode 
	
	HW_Script_RemovePluginFile
	return
}

#creat files
HW_Script_CreateFile()
{
	var_telnet_flag=/mnt/jffs2/ProductLineMode

	echo "" > $var_telnet_flag
	if [ 0 -ne $? ]
	then
	{
		echo "ERROR::Failed to create telnet flag!"
	return 1
	}
	fi

	return 0
}

# copy files
HW_Script_CopyFile()
{
	var_etc_def=/etc/wap/hw_default_ctree.xml
	
	#增加延时，确保DB不保存
	echo > /var/notsavedata
	sleep 1

	cp -f $var_etc_def $var_ctree
	if [ 0 -ne $? ]
	then
		rm -rf /var/notsavedata
		echo "ERROR::Failed to cp hw_default_ctree.xml to hw_ctree.xml!"
		return 1
	fi

	return
}

# set spec data
HW_Script_SetData()
{
	cat $var_boardinfo_file | while read -r line;
	do
		obj_id_temp=`echo $line | sed 's/\(.*\)obj.value\(.*\)/\1/g'`
		obj_id=`echo $obj_id_temp | sed 's/\(.*\)"\(.*\)"\(.*\)/\2/g'`

		if [ "0x00000003" == $obj_id ];then
			echo "obj.id = \"0x00000003\" ; obj.value = \"\";"
		elif [ "0x00000004" == $obj_id ];then
			echo "obj.id = \"0x00000004\" ; obj.value = \"\";"
		elif [ "0x00000005" == $obj_id ];then
			echo "obj.id = \"0x00000005\" ; obj.value = \"\";"
		elif [ "0x00000006" == $obj_id ];then
			echo "obj.id = \"0x00000006\" ; obj.value = \"\";"
		elif [ "0x00000016" == $obj_id ];then
			echo "obj.id = \"0x00000016\" ; obj.value = \"\";"
		elif [ "0x0000001a" == $obj_id ];then
			echo "obj.id = \"0x0000001a\" ; obj.value = \"COMMON\";"
		elif [ "0x0000001b" == $obj_id ];then
			echo "obj.id = \"0x0000001b\" ; obj.value = \"COMMON\";"
		elif [ "0x00000019" == $obj_id ];then
			echo "obj.id = \"0x00000019\" ; obj.value = \"\";"
		elif [ "0x00000020" == $obj_id ];then
			echo "obj.id = \"0x00000020\" ; obj.value = \"\";"
		elif [ "0x00000031" == $obj_id ];then
			echo "obj.id = \"0x00000031\" ; obj.value = \"NOCHOOSE\";"
		elif [ "0x00000035" == $obj_id ];then
			echo "obj.id = \"0x00000035\" ; obj.value = \"\";"
		elif [ "0x0000003a" == $obj_id ];then
			echo "obj.id = \"0x0000003a\" ; obj.value = \"\";"
		elif [ "0x00000060" == $obj_id ];then
			echo "obj.id = \"0x00000060\" ; obj.value = \"\";"
		else
			echo -E $line
		fi
	done  > $var_boardinfo_temp

	mv -f $var_boardinfo_temp $var_boardinfo_file

	return
}

# 刷新boardinfo文件的crc行
HW_Customize_ValidateBoardinfoCRC()
{
	if [ -z $1 ]; then
		return 0
	fi
	if [ -x /bin/factparam ]; then
		/bin/factparam -v $1
		if [ 0 -ne $? ]; then
			echo "ERROR::Failed to validate boardinfo crc on $1!"
			return 1
		fi
	fi
}

# 清除出厂参数备份
HW_Customize_ClearFactoryParamsBackup()
{
	if [ -x /bin/factparam ]; then
		/bin/factparam -e reserved
		if [ 0 -ne $? ]; then
			echo "ERROR::Failed to clear factory parameter backup area!"
			return 1
		fi
	fi
}

if [ 0 -ne $# ]; then
	echo "ERROR::input para is not right!";
	exit 1;
else
HW_Script_CreateFile
[ ! $? == 0 ] && exit 1

HW_Script_RemoveFile
[ ! $? == 0 ] && exit 1

HW_Script_CopyFile
[ ! $? == 0 ] && exit 1

HW_Script_SetData
[ ! $? == 0 ] && exit 1

rm -rf $var_boardinfo_bakfile

procid=`pidof saf-huawei`
ctrg_support=`GetFeature HW_SSMP_FEATURE_CTRG`
if [ $ctrg_support = 1 ] && [ "$procid" != "" ] ;then
	dbus-send --system --print-reply --dest=com.ctc.saf1 /com/ctc/saf1 com.ctc.saf1.framework.Restore > /dev/null
fi

# 必须刷新boardinfo文件的crc行，并且清除reserved分区的出厂参数备份
HW_Customize_ValidateBoardinfoCRC $var_boardinfo_file
[ ! $? == 0 ] && exit 1
HW_Customize_ClearFactoryParamsBackup
[ ! $? == 0 ] && exit 1

echo "success!"

exit 0
fi

