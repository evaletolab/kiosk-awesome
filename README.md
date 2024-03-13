## Build Video Player 

* cd video-player
* npm install
* bpm build

### Build Ubuntu Image
* cd os

* sudo ./kiosk-chroot.sh
* insine chrooted image, run /kiosk-installer.sh

### Create GRUB bootable Image (.ISO)

* sudo ./kiosk-grub.sh

### Write Image on USB

* sudo ./kiosk-writeusb.sh

### Add http partition on USB

* gparted /dev/sda (vfat32)
* bash ./kiosk-installapp.sh


## Furthermore 
* https://willhaley.com/blog/custom-debian-live-environment/
* https://www.kali.org/docs/usb/live-usb-install-with-linux/
* https://github.com/josfaber/debian-kiosk-installer/


# kiosk-awesome
