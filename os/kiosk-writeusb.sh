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



[ ! -f "${LIVE_BOOT}/meg-custom.iso" ] && {
  echo "missing img ${LIVE_BOOT}/meg-custom.iso, usage: sudo ./kiosk-grub.sh "
  echo "bye!"
  exit;
}

#
# help: resize image
# dd if=/dev/zero bs=4M count=500 >> yourfile.ext4
# resize2fs yourfile.ext4


# mount usb
umount /dev/sda
dd bs=4M if=${LIVE_BOOT}/meg-custom.iso  of=/dev/sda conv=fdatasync  status=progress

test $? -eq 0 || {
  echo "something bad happened"
  exit;
}

#
# help: create part   start  end
parted /dev/sda mkpart primary ext4 850MB 8154MB
umount /dev/sda1
mkfs.ext4 /dev/sda1
umount /dev/sda1
echo "sudo chmod a+w /media/mount/dest"


#dd bs=100MB if=/dev/sda  of=/dev/sdb conv=fdatasync  status=progress count=95
cleanup
