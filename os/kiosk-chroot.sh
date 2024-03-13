#!/bin/bash
# https://wiki.debian.org/chroot

#
# simple check
export CHROOT_FS_SZ=2800
export LIVE_BOOT=live-debianfs
export CHROOT_HOME=$LIVE_BOOT/chroot
export CHROOT_FS=./chroot.debianfs
export USER=kiosk
export LC_ALL=C
export UBUNTUREL=focal #$(lsb_release -sc)
WIM=$(whoami)
[ "$WIM" = "root" ] || {
  echo "not sudo, exit..."
  exit;
}


[ -z "$HOME" ] && {
  echo "home is not define, bye!"
  exit;
}

[ -z "$CHROOT_HOME" ] && {
  echo "chroot home is not define, bye!"
  exit;
}

#
# security
[ ! -d "$CHROOT_HOME" ] && {
  mkdir -p $CHROOT_HOME
}

#
# install
[ "$1" = "install" ] && {
  [ -z "$2" ] && {
    echo "usage: sudo bash boot.sh install <account-short-name>"
    exit;
  }

  [ -f "$CHROOT_HOME/proc/partitions" ] && {
    echo "Already mounted chroot"
    exit;
  }
  
  which debootstrap 1>/dev/null ||{
    echo "install debootstrap before to run the script"
    exit;
  
  }
  
  [ ! -f "$CHROOT_FS" ] || {
    echo "one chroot filesystem already exist: $CHROOT_FS"
    exit;
  }
  echo "install chroot"
  dd if=/dev/zero of=$CHROOT_FS bs=1M count=$CHROOT_FS_SZ
  mkfs.ext4 $CHROOT_FS 
  [ ! -f "$CHROOT_HOME/proc/partitions" ] && mount -o loop $CHROOT_FS $CHROOT_HOME
  
  # copying script inside protected chroot
  export HOME=/root SUDO_UID=0 SUDO_USER=root
  
  #debian => wheezy, http://httpredir.debian.org/debian
  debootstrap --include=git,curl,nano,libusb-1.0-0-dev,libudev-dev,software-properties-common --variant=minbase --arch amd64 $UBUNTUREL  $CHROOT_HOME http://archive.ubuntu.com/ubuntu/


  #kiosk installer 
  cp kiosk-installer.sh $CHROOT_HOME
  [ ! -f "$CHROOT_HOME/kiosk-installer.sh" ] && {
    echo "missing installer: $CHROOT_HOME/kiosk-installer.sh"
    exit;
  }
  
  echo "-----"
  echo "----- running kiosk installation"
  echo "-----"
  
  chroot $CHROOT_HOME bash -c 'echo "deb http://archive.ubuntu.com/ubuntu $UBUNTUREL universe">>/etc/apt/sources.list'
  chroot $CHROOT_HOME bash -c '/kiosk-installer.sh'
  

  chroot $CHROOT_HOME bash -c "echo PS1=\'unset HISTFILE\'>>~/.bashrc"
  chroot $CHROOT_HOME bash -c "echo PS1=\'\\\[\\\e[1\;31m\\\]\\\u-$2@\\\h\:\\\w\${text}$\\\[\\\e[m\\\] \'>>~/.bashrc"
  chroot $CHROOT_HOME bash -c "echo cowsay 'welcome $2! type cat HELP.md'>>~/.bashrc"

  cp HELP.md $CHROOT_HOME/home/$USER/
#  chroot $CHROOT_HOME secu -l $USER -c "source .profile;nvm install stable;npm install"  
  umount $CHROOT_HOME
  echo "installation is done! "
  exit;
} 

#/usr/bin/sudo /usr/sbin/chroot /usr/local/jail /bin/su $USER "$@"

[ ! -f "$CHROOT_FS" ] && {
  echo "missing image file, bye! : ${CHROOT_FS}"
  exit;
}

#
# default usage
[ ! -f "$CHROOT_HOME/proc/partitions" ] && {
  mount -o loop $CHROOT_FS $CHROOT_HOME
  mount --bind /dev $CHROOT_HOME/dev
  mount --bind /proc $CHROOT_HOME/proc
#  mount -t sysfs $CHROOT_HOME/sys
  mount -t devpts none $CHROOT_HOME/dev/pts

  #sudo mount --bind /proc $CHROOT_HOME/proc
}

export HOME=/root
unset HISTFILE
echo "Starting $CHROOT_FS in protected $CHROOT_HOME"
chroot $CHROOT_HOME su -l root
for i in dev/pts proc dev
do
    umount $CHROOT_HOME/$i
done
umount $CHROOT_HOME

