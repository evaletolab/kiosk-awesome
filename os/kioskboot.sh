#
# configure audio
export MEGCARDS=$(echo /proc/asound/card[01])
if [ ! -d "/proc/asound/card0" ];then
echo "defaults.pcm.card 1" > ~/.asound.conf
echo "defaults.ctl.card 1" >> ~/.asound.conf
sudo bash -c 'cat /home/kiosk/.asound.conf > /etc/asound.conf'
amixer -c 1 set Master 90%
else
amixer set Master 90%
fi


#
# load network
NETDEV=$(ip -o link show | awk -F': ' '{print $2}' | grep  ^en -m 1)
#[ -n "$NETDEV" ] &&  NETDEV=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
[ -n "$NETDEV" ] && {
  sudo bash -c "echo \"iface $NETDEV inet dhcp\" >> /etc/network/interfaces"
  sudo bash -c "ifup $NETDEV &"
  sleep 2
}

