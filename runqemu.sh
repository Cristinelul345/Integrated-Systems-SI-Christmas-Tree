#!/bin/bash
# Qemu Yocto image runner helper
# (since meta-raspberrypi doesn't do it)

## Yocto build output paths
YOCTO_MACHINE=${YOCTO_MACHINE:-"qemuarm"}
YOCTO_IMAGE_DIR="build/tmp/deploy/images/$YOCTO_MACHINE"

## Required kernel / rootfs files
ROOTFS_IMG_FILE=${ROOTFS_IMG_FILE:-"core-image-base-$YOCTO_MACHINE.wic"}
KERNEL_FILE=${KERNEL_FILE:-"zImage"}
DTB_FILE=${DTB_FILE:-"bcm2709-rpi-2-b.dtb"}

## Enter the Yocto deploy dir where the boot files are present
if [[ -d "$YOCTO_IMAGE_DIR" ]]; then cd "$YOCTO_IMAGE_DIR"; fi

## build the required kernel cmdline arguments as bash variable:
# enable console + debug logging for early issues
KERNEL_CMDLINE="console=ttyAMA0,115200 earlyprintk loglevel=8 "
# rootfs mount options
KERNEL_CMDLINE+="root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4 "
# Emulated USB Host controller workarounds for RPIs
KERNEL_CMDLINE+="dwc_otg.lpm_enable=0 "
# Tell Linux to give us old school interface names (e.g., eth0)
KERNEL_CMDLINE+="net.ifnames=0 "

## Qemu's arguments; yep, this is a bash array ;)
QEMU_ARGS=(
    # Yep, we emulate a RPI2 (qemu's raspi3 is 64-bit only)
    -machine raspi2b -cpu arm1176 -m 1G
    #-drive "file=$ROOTFS_IMG_FILE,if=none,id=usbstick,format=raw" -device "usb-storage,drive=usbstick"
    -device "sd-card,drive=mmc" -drive "id=mmc,if=none,format=raw,file=$ROOTFS_IMG_FILE"
    -device "usb-kbd"
    -kernel "$KERNEL_FILE"
    -dtb "$DTB_FILE"
    -append "$KERNEL_CMDLINE"
    -serial mon:stdio -nographic
    #-monitor telnet::45454,server,nowait
    #-no-reboot
)

# append networking configuration (forward ssh && http)
QEMU_NET_FWD="hostfwd=tcp::5555-:22,hostfwd=tcp::8888-:80"
QEMU_ARGS+=(
    -device usb-net,netdev=net0 
    -netdev user,id=net0,$QEMU_NET_FWD
)

# resize the image to be a power of two
qemu-img resize -f raw "$ROOTFS_IMG_FILE" 1G

# finally, call qemu
exec qemu-system-arm "${QEMU_ARGS[@]}"

