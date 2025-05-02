### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developers
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
## end boot install
    ui_print "KernelSU Next SUSFS内核刷入完成✅"
# 作者  
    ui_print " "     
    ui_print "此内核由 @秋詞 编译"
    ui_print "感谢@云樊_ @一只橡皮擦 @空白没有输 @习惯 @饿魂" 
    
# 检测 KSU是否已安装
if pm list packages -3 | grep me.weishu.kernelsu; then
    ui_print " "
    ui_print "已安装 KernelSU管理器，正在卸载..."
    ui_print " "
    # 卸载 KSU
    pm uninstall --user 0 me.weishu.kernelsu
    ui_print " "
    ui_print "KernelSU管理器 已卸载完成✅"
    ui_print " "
else
    ui_print " "
    ui_print "未安装 KernelSU管理器。"
    ui_print " "
fi


if pm list packages -3 | grep com.rifsxd.ksunext; then
    ui_print " "
    ui_print "已安装 KernelSU_Next管理器✅"
    ui_print " "
else
    ui_print " "
    ui_print "正在安装 KernelSU_Next管理器"
    ui_print ""
    pm install $AKHOME/KernelSU_Next.apk
    ui_print " "
    ui_print "已安装 KernelSU_Next管理器✅"
    ui_print " "
fi

## install additional module
    ui_print " "
    ui_print "正在安装 SUSFS 模块..."
    ui_print " "
    if /data/adb/ksud module install $AKHOME/ksu_module_susfs_*.zip; then
    ui_print "安装成功 SUSFS 模块✅ "
else
    ui_print "安装失败 SUSFS 模块❎ "
    ui_print " "
    ui_print "显示安装失败/错误可直接重启"
    ui_print " "
    ui_print "如果是非KSU用户,请重启后重新刷入此内核"
    ui_print " "
    ui_print "并在重启后完全卸载其他ROOT权限"
fi
    
    

