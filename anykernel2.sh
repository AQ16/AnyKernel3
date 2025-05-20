### AnyKernel3 Ramdisk Mod Script
## KernelSU with SUSFS By Numbersf
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developers | Built by Numbersf
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
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

ui_print "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# 确定 root 方式
if [ -d /data/adb/magisk ] || [ -f /sbin/.magisk ]; then
    ui_print "检测到 Magisk，当前 Root 方式为 Magisk。在此情况下刷写 KSU 内核有很大可能会导致你的设备变砖，是否要继续？"
    ui_print "请选择操作："
    ui_print "音量上键：退出脚本"
    ui_print "音量下键：继续安装"
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done
    case "$key_click" in
        "KEY_VOLUMEUP") 
            ui_print "您选择了退出脚本"
            exit 0
            ;;
        "KEY_VOLUMEDOWN")
            ui_print "您已选择继续安装"
            ;;
        *)
            ui_print "未知按键，退出脚本"
            exit 1
            ;;
    esac
fi

ui_print "开始安装内核..."
ui_print "Power by GitHub@Numbersf(Aq1298&咿云冷雨)"
ui_print "GitHub Actions by QQQiuCi "
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" ] || [ -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot
    flash_boot
    ui_print "内核刷入完成！！！ "
    ui_print "记得按音量下键安装模块！"
else
    dump_boot
    write_boot
    ui_print "内核刷入完成！！！ "
    ui_print "记得按音量下键安装模块！"
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
ui_print "安装 SUSFS 模块？音量上跳过安装；音量下安装模块"


key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done
case "$key_click" in
    "KEY_VOLUMEDOWN")
        if [ -f "$KSUD_PATH" ]; then
            ui_print "正在安装 SUSFS 模块..."
            /data/adb/ksud module install "$MODULE_PATH"
            ui_print "安装成功！"
        else
            [ ! -f "$KSUD_PATH" ] && ui_print "错误：未找到 KSUD，跳过安装"
        fi
        ;;
    "KEY_VOLUMEUP")
        ui_print "跳过 SUSFS 模块安装"
        ;;
    *)
        ui_print "未知按键输入，跳过安装"
        ;;
esac
# LZ4KD-ZRAM 模块安装逻辑
ui_print "安装 LZ4KD-ZRAM 模块？音量上跳过安装；音量下安装模块"


key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done

case "$key_click" in
    "KEY_VOLUMEDOWN")
        if [ -f "$KSUD_PATH" ] && [ -f "$AKHOME/ZRAM_Lz4kd.zip" ]; then
            ui_print "正在安装 LZ4KD-ZRAM 模块..."
            /data/adb/ksud module install "$AKHOME/ZRAM_Lz4kd.zip"
            ui_print "安装成功！"
            ui_print "如果内核不支持 lz4kd，此模块将在下次重启后自动删除。"
            ui_print "此模块将zRAM的压缩算法设置为 lz4kd"
            ui_print "并将zRAM大小调整为物理内存的1.5倍。"
        else
            [ ! -f "$KSUD_PATH" ] && ui_print "错误：未找到 KSUD，跳过安装"
            [ ! -f "$AKHOME/ZRAM_Lz4kd.zip" ] && ui_print "错误：模块文件缺失，跳过安装"
        fi
        ;;
    "KEY_VOLUMEUP")
        ui_print "跳过 LZ4KD-ZRAM 模块安装"
        ;;
    *)
        ui_print "未知按键输入，跳过安装"
        ;;
esac        
