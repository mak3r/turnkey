#!/bin/bash
set -x

# configure dhcpcd
cat <<EOF >> /etc/dhcpcd.conf

interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

# configuration done, restart dhcpcd
/usr/lib/dhcpcd5/dhcpcd -q -b

# Create a new dnsmasq configuration for this device
cat <<EOF >> /etc/dnsmasq.conf
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

# Test dnsmasq config before we commit to starting it up
/usr/sbin/dnsmasq --test
# startup the dnsmasq service
/etc/init.d/dnsmasq systemd-exec
# startup resolv.conf 
/etc/init.d/dnsmasq start_resolvconf


# setup hostapd configuration
cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=ConfigureK3s
hw_mode=a
channel=44
ieee80211d=1
country_code=US
ieee80211n=1
ieee80211ac=1
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=rancher-k3s
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# fire up hostapd
DAEMON_CONF=/etc/hostapd/hostapd.conf
/usr/sbin/hostapd -B -P /run/hostapd.pid -B $DAEMON_OPTS ${DAEMON_CONF}


# # configure network interfaces
# cp /app/interfaces/wlan0 /etc/network/interfaces.d/.
# cp /app/interfaces/eth0 /etc/network/interfaces.d/.

# # enable ip forwarding 
# sed -i.bak 's/\(#\)\(net\.ipv4\.ip_forward\)/\2/' /etc/sysctl.conf 

# setup a MASQUERADE for traffic talking to this gateway
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# save the rule
iptables-save > /etc/iptables.ipv4.nat

# make sure the iptables rule sticks on boot
cp /etc/rc.local /etc/rc.local.orig
sed -i.bak '0,/^exit 0/s/^exit 0/iptables-restore < \/etc\/iptables\.ipv4\.nat\n&/'  /etc/rc.local
# sed -i.bak '0,/^exit 0/s/^exit 0/\/usr\/bin\/python3 \/var\/lib\/rancher\/turnkey\/startup.py\n&/'  /etc/rc.local

# # setup a tmp log for rc.local just in case the prior commands need debugging
# sed -i.bak '0,/^$/s/^$/exec 2> \/tmp\/rc.local.log      # send stderr from rc.local to a log file\n&/' /etc/rc.local
# sed -i.bak '0,/^$/s/^$/exec 1>&2                      # send stdout to the same log file\n&/' /etc/rc.local
# sed -i.bak '0,/^$/s/^$/set -x                         # tell sh to display commands before execution\n&/' /etc/rc.local

