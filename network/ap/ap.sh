#!/bin/bash
set -x

function init()
{
	# configure dhcpcd
	cat <<-'EOF' >> /etc/dhcpcd.conf

	interface wlan0
	    static ip_address=192.168.4.1/24
	    nohook wpa_supplicant 
	EOF

	# Create a new dnsmasq configuration for this device
	cat <<-EOF >> /etc/dnsmasq.conf
	interface=wlan0
	dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
	EOF

	# setup hostapd configuration
	cat <<-EOF > /etc/hostapd/hostapd.conf
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

}

function ap_up()
{
    ip link set wlan0 up
    ip addr flush dev wlan0
    ip addr add 192.168.4.1/24 dev wlan0

    # turn on dhcpcd
    /usr/sbin/dhcpcd -q -b

    # Test dnsmasq config before we commit to starting it up
    /usr/sbin/dnsmasq --test
    if [ "$?" -eq "0" ]; then
        # startup the dnsmasq service
        /etc/init.d/dnsmasq systemd-exec
        # startup resolv.conf 
        /etc/init.d/dnsmasq systemd-start-resolvconf
    else
        echo dnsmasq cannot be started
        exit 0
    fi

    # fire up hostapd
    DAEMON_CONF=/etc/hostapd/hostapd.conf
    /usr/sbin/hostapd -B -P /run/hostapd.pid ${DAEMON_CONF}

    wait $!

    # enable ip forwarding 
    echo "1" > /proc/sys/net/ipv4/ip_forward

    # setup a MASQUERADE for traffic talking to this gateway
    iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    # save the rule
    iptables-save > /etc/iptables.ipv4.nat
}

function ap_down()
{
    ip link set wlan0 down
}

function reset()
{
    # TODO: RELOAD CONFIGURATION FILES
    ap_down
	wait $!
    ap_up
}    

trap ap_down SIGTERM
trap reset SIGUSR1

init
reset
while true
do
    sleep 10
done