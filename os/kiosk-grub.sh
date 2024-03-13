#!/bin/bash
# install GRUB boot
# sudo apt install \
#     debootstrap \
#     squashfs-tools \
#     xorriso \
#     isolinux \
#     syslinux-efi \
#     grub-pc-bin \
#     grub-efi-amd64-bin \
#     mtools



#
# simple check
export LIVE_BOOT=live-debianfs
export CHROOT_HOME=$LIVE_BOOT/chroot
export CHROOT_FS=./chroot.debianfs
export USER=kiosk
export LC_ALL=C

#
# clean before exit
cleanup() { 
  umount --force $CHROOT_HOME
  echo "create usb image: sudo dd bs=4M if=${LIVE_BOOT}/meg-custom.iso of=/dev/sda conv=fdatasync  status=progress"
  echo "Exit normally..."
}
trap cleanup INT TERM SIGTERM


[ -z "$CHROOT_HOME" ] && {
  echo "chroot home is not define, bye!"
  exit;
}

[ ! -f "$CHROOT_FS" ] && {
  echo "missing file $CHROOT_FS, usage: sudo ./kiosk-chroot.sh "
  echo "bye!"
  exit;
}


[ -f "$CHROOT_HOME/proc/partitions" ] && {
  echo "chroot  mounted, please exit kiosk-chroot.sh"
  echo "bye!"
  exit;
}


# mount filesystem
mount -o loop $CHROOT_FS $CHROOT_HOME

#
# embed player
# 
[ -f "../video-player/dist/index.html" ] && {
  echo "install latest player"
  #rsync -av --exclude='*.mp4' ../video-player/dist/* $LIVE_BOOT/chroot/var/www/html/
}


rm -rf $LIVE_BOOT/staging
mkdir -p $LIVE_BOOT/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

sudo mksquashfs \
    $LIVE_BOOT/chroot \
    $LIVE_BOOT/staging/live/filesystem.squashfs \
    -e boot


cp $LIVE_BOOT/chroot/boot/vmlinuz-* \
    $LIVE_BOOT/staging/live/vmlinuz && \
cp $LIVE_BOOT/chroot/boot/initrd.img-* \
    $LIVE_BOOT/staging/live/initrd

#
#
# Prepare Boot Loader
# https://willhaley.com/blog/custom-debian-live-environment/
#

cat <<'EOF' >$LIVE_BOOT/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 50
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL MEG Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live 

LABEL linux
  MENU LABEL MEG Live [debug]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live  megdebug

LABEL linux
  MENU LABEL MEG Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF


cat <<'EOF' >$LIVE_BOOT/staging/boot/grub/grub.cfg
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=8

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "MEG Live [EFI/GRUB]" {
    linux ($root)/live/vmlinuz boot=live 
    initrd ($root)/live/initrd
}

menuentry "MEG Live [debug]" {
    linux ($root)/live/vmlinuz boot=live megdebug
    initrd ($root)/live/initrd
}

menuentry "MEG Live [EFI/GRUB] (nomodeset)" {
    linux ($root)/live/vmlinuz boot=live nomodeset megdebug
    initrd ($root)/live/initrd
}
EOF

cat <<'EOF' >$LIVE_BOOT/tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF


touch $LIVE_BOOT/staging/DEBIAN_CUSTOM
find $LIVE_BOOT/staging

#
# Prepare Boot Loader Files
#
cp /usr/lib/ISOLINUX/isolinux.bin "${LIVE_BOOT}/staging/isolinux/" && \
cp /usr/lib/syslinux/modules/bios/* "${LIVE_BOOT}/staging/isolinux/"

cp -r /usr/lib/grub/x86_64-efi/* "${LIVE_BOOT}/staging/boot/grub/x86_64-efi/"


grub-mkstandalone \
    --format=x86_64-efi \
    --output=$LIVE_BOOT/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=${LIVE_BOOT}/tmp/grub-standalone.cfg"

( 
  cd $LIVE_BOOT/staging/EFI/boot;
  dd if=/dev/zero of=efiboot.img bs=1M count=20;
  mkfs.vfat efiboot.img;mmd -i efiboot.img efi;
  mmd -i efiboot.img efi/boot;mcopy -i efiboot.img ../../../tmp/bootx64.efi ::efi/boot/
)



#
# Create Bootable ISO/CD
#
xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "${LIVE_BOOT}/meg-custom.iso" \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e /EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xef ${LIVE_BOOT}/staging/EFI/boot/efiboot.img \
    "${LIVE_BOOT}/staging"


cleanup