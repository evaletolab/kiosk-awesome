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
  echo "create usb image: sudo dd bs=4M if=${LIVE_BOOT}/meg-custom.iso of=/dev/sda conv=fdatasync  status=progress"
  echo "Exit normally..."
}
trap cleanup INT TERM SIGTERM

[ ! -e "/dev/sda" ] && {
  echo "missing usb src /dev/sda"
  echo "bye!"
  exit;
}

[ ! -e "/dev/sdb" ] && {
  echo "missing usb dest /dev/sdb"
  echo "bye!"
  exit;
}

umount /dev/sda1
umount /dev/sdb1


dd bs=100MB if=/dev/sda  of=/dev/sdb conv=fdatasync  status=progress count=100
cleanup
