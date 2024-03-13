#!/bin/bash

[ ! -f "/home/kiosk/HELP.md" ] && {
  echo "wrong place to run,  home/kiosk/HELP.md should exists"
  echo "sure?"
  sleep 4;
}


# be new
# get chromium
add-apt-repository -y ppa:saiarcot895/chromium-beta
apt-get update

# apt-get install --yes dbus
# dbus-uuidgen > /var/lib/dbus/machine-id
# dpkg-divert --local --rename --add /sbin/initctl
# ln -s /bin/true /sbin/initctl

# Install packages needed for Live System:
# FIXME: those package should be manually reinstalled.
apt install --yes --no-install-recommends \
    linux-image-generic \
    live-boot \
    systemd-sysv \
    cron \
    alsa-utils \
    libnotify4 \
    ifupdown \
    isc-dhcp-client \
    dbus-user-session

apt --yes --fix-broken install
apt clean

# get software
apt-get install --yes --no-install-recommends \
    unclutter \
    xorg \
    xinput \
    vim \
    xserver-xorg-video-nouveau \
    xserver-xorg-video-intel \
    intel-media-va-driver \
    chromium-browser \
    chromium-codecs-ffmpeg \
    openbox \
    lightdm \
    cowsay \
    gawk \
    sudo \
    locales

# network
apt install --yes --no-install-recommends \
    network-manager net-tools wireless-tools wpagui \
    curl openssh-client \
    blackbox xserver-xorg-core xserver-xorg xinit xterm \
    nano

# local server
apt install --yes --no-install-recommends nginx    

apt clean

# set timezone
echo "Europe/Zurich" > /etc/timezone
ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime

# dir
mkdir -p /home/kiosk/.config/openbox

# create group
groupadd kiosk

# create user if not exists
id -u kiosk &>/dev/null || useradd -m kiosk -g kiosk -s /bin/bash 

# rights
chown -R kiosk:kiosk /home/kiosk

cat >> /etc/sudoers << EOF

kiosk ALL=NOPASSWD: /usr/bin/mount  
kiosk ALL=NOPASSWD: /usr/bin/umount 
kiosk ALL=NOPASSWD: /bin/bash 

EOF

cat >> /home/kiosk/.bashrc << EOF

EOF

echo PS1=\'unset HISTFILE\'>>/home/kiosk/.bashrc
echo PS1=\'\\\[\\\e[1\;31m\\\]\\\u-$2@\\\h\:\\\w\${text}$\\\[\\\e[m\\\] \'>>/home/kiosk/.bashrc
echo cowsay 'welcome $2! type cat HELP.md'>>/home/kiosk/.bashrc

cat > /home/kiosk/HELP.md << EOF
1. hwclock --set --date "8/11/2013 23:10:45"
EOF

# network
#cat > /etc/network/interfaces << EOF
#auto lo
#iface lo inet loopback
#
## To use dhcp:
##
#auto eth0
#iface eth0 inet dhcp
#EOF

# remove virtual consoles
if [ -e "/etc/X11/xorg.conf" ]; then
  mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
fi
cat > /etc/X11/xorg.conf << EOF
Section "ServerFlags"
    Option "DontVTSwitch" "true"
EndSection


Section "Device"
  Identifier "Card0"
  Option "TearFree"   "true"
  Driver "intel"
EndSection

EOF

cat > /etc/modprobe.d/hdmi-alsa.conf << EOF
# image DSIC , issue with HDMI
options snd-hda-intel id=PCH index=0
options snd-hda-intel id=HDMI index=1
#blacklist snd_hda_codec_hdmi
EOF

#
# shutdown kiosk at 20:30
cat > /etc/crontab << EOF
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the crontab
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

0 23 * * * root /usr/sbin/shutdown -h now

EOF

# create config
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=kiosk
EOF

cat > /home/kiosk/.dmrc << EOF
[Desktop]
Session=openbox
EOF

# in case of xserver-command is not working
cat > /etc/X11/xinit/xinitrc << EOF
#!/bin/sh
# invoke global X session script
. /etc/X11/Xsession

xset -dpms
xset s off
xset s noblank
EOF

# create autostart
if [ -e "/home/kiosk/.config/openbox/autostart" ]; then
  mv /home/kiosk/.config/openbox/autostart /home/kiosk/.config/openbox/autostart.backup
fi

cat > /home/kiosk/.config/openbox/autostart << EOF
#!/bin/bash


# setup
MEGMOUNT="\$(mount | gawk 'match(\$0, /(dev\/[a-z]*).*live\/medium /, a) {print a[1]}')"
#
# iso9960 is always mounted as a disk /dev/sda but our partition is always number 2
export MEGMOUNT="/\${MEGMOUNT}1"

[ -e "\$MEGMOUNT" ] && {
  sudo mount -o loop "\$MEGMOUNT" /var/www/html
}

xset -dpms
xset s off
xset s noblank

[ -f "/var/www/html/.kioskboot.sh" ] && {
  bash -c /var/www/html/.kioskboot.sh
}

[ -f "/var/www/html/.kioskshell.sh" ] && {
  bash -c /var/www/html/.kioskshell.sh
}


export DEBUG="\$(cat /proc/cmdline|grep -o 'megdebug')"
[ -n "\$DEBUG" ] && {
  xterm
}


while :
do
  chromium-browser \
    --no-first-run \
    --start-maximized \
    --window-position=0,0 \
    --disable \
    --disable-translate \
    --disable-infobars \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --disable-session-crashed-bubble \
    --incognito \
    --kiosk "http://localhost/"
  sleep 5
done &
EOF



echo "Done!"
