### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers
### AnyKernel setup
# global properties
#!/bin/bash
properties() { '
kernel.string=Wild Plus Kernel by TheWildJames or Morgan Weedman
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
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
    ui_print "内核刷入完成！！！ "
else
    dump_boot
    write_boot
    ui_print "内核刷入完成！！！ "
fi

# 优先选择模块路径
if [ -f "$AKHOME/ksu_module_susfs_1.5.2+_Release.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_Release.zip"
    ui_print "  -> Installing SUSFS module from Release"
elif [ -f "$AKHOME/ksu_module_susfs_1.5.2+_CI.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_CI.zip"
    ui_print "  -> Installing SUSFS module from CI"
else
    ui_print "  -> No SUSFS module found, skipping installation"
    MODULE_PATH=""
fi

KSUD_PATH="/data/adb/ksud"
        if [ -f "$KSUD_PATH" ]; then
            ui_print "正在安装 SUSFS 模块..."
            /data/adb/ksud module install "$MODULE_PATH"
            ui_print "安装成功！"
        else
            [ ! -f "$KSUD_PATH" ] && ui_print "错误：未找到 KSUD，跳过安装"
        fi
