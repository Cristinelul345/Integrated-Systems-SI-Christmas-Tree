#!/bin/bash
IMAGE_FILE="rootfs.img"
KERNEL_FILE="kernel"

# to make the script usable from source dir, use after calling `make bin_archive`
BIN_TMP_DIR="build/tmp/bin_archive/"
if [[ ! -d "$BIN_TMP_DIR" ]]; then
    echo "Please generate the binary archive ('$BIN_TMP_DIR' must exist)"
    exit 1
fi

cd "$BIN_TMP_DIR"

# disable audio (for qemu 2.x)
export QEMU_AUDIO_DRV=none

QEMU_ARGS=( # yep, this is a bash array
	# NOTE: use Qemu machine type 'virt' instead of 'versatilepb' for
	# compatibility with Yocto's 'qemuarm' arch; also, this doesn't require
	# a device tree ;)
	-machine virt,highmem=off -cpu cortex-a15 -m 256
	-drive "file=$IMAGE_FILE,if=none,media=disk,format=raw,id=disk0"
	-device "virtio-blk-pci,drive=disk0,disable-modern=on"
	-kernel "$KERNEL_FILE"
	-append "console=ttyAMA0 root=/dev/vda rw ip=dhcp"
	-serial mon:stdio -nographic
	-monitor telnet::45454,server,nowait
	-no-reboot
)

# append networking configuration (forward ssh && http)
QEMU_NET_FWD="hostfwd=tcp::5555-:22,hostfwd=tcp::8888-:80"
QEMU_ARGS+=(
    -device virtio-net-device,netdev=net0,mac=52:54:00:12:35:02
    -netdev user,id=net0,$QEMU_NET_FWD
)

echo qemu-system-arm "${QEMU_ARGS[@]}"
exec qemu-system-arm "${QEMU_ARGS[@]}"

