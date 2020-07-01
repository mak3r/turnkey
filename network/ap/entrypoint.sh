#!/bin/bash
set -x

while getopts h flag
do
    case "${flag}" in
        h) echo "ap.sh [up|down|reset]"; 
			exit 0
			;;
    esac
done


function ap_up()
{
    ip link set wlan0 up
    ip addr flush dev wlan0
    ip addr add 192.168.4.1/24 dev wlan0

    # turn on dhcpcd
    /usr/sbin/dhcpcd -q -b

    # Test dnsmasq config before we commit to starting it up
    /usr/sbin/dnsmasq --test
    if [ "$?" == "0" ]; then
        # startup the dnsmasq service
        /etc/init.d/dnsmasq systemd-exec
        # startup resolv.conf 
        /etc/init.d/dnsmasq systemd-start-resolvconf
    else
        echo dnsmasq cannot be started
        exit 1
    fi

    # fire up hostapd
    DAEMON_CONF=/etc/hostapd/hostapd.conf
    /usr/sbin/hostapd -B -f /root/hostapd.out ${DAEMON_CONF}

    wait $!

	if grep -e "Unable to setup interface" /root/hostapd.out; then
		exit 1
	fi 
	# flush the network adapter after hostapd comes up
	ip addr flush dev wlan0

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
    ap_down
	wait $!
    ap_up
}    

trap ap_down SIGTERM
trap reset SIGUSR1

if [ "$1" == "reset" ] 
then
	reset
elif [ "$1" == "down" ]
then
	ap_down
elif [ "$1" == "up" ]
then
	ap_up
fi

# Status
# up - hostapd service should be up
# down - exit 
# sleep - hostapd service should be down, maintain listening loop
status='up'
cur=$status
prev=$status
until [ "$status" == "down" ]
do
	status=$(cat /var/lib/rancher/turnkey/status)
	cur=$status
	if [ "$status" == "sleep" ] && [ "$cur" != "$prev" ]
	then
		# continue logging
		set -x
		ap_down
	elif [ "$status" == "up" ] && [ "$cur" != "$prev" ]
	then 
		# continue logging
		set -x
		ap_up
	fi
	prev=$cur

	sleep 5
	# stop debugging at the end of the loop
	set +x
done

set -x
# be sure the ap is down when exiting
ap_down