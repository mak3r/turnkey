#!/bin/bash
set -x

while getopts h flag
do
    case "${flag}" in
        h) echo "wifi.sh [up|down|reset|scan]"
			exit 0
			;;
    esac
done

function ip_up()
{
	ip link set wlan0 up
	ip addr flush dev wlan0
}

function down()
{
    ip link set wlan0 down
}

function get_wlan0_ip() 
{
	ip r | grep -e "default" | grep -e "wlan0" | awk '{print $3}'
}

function up()
{
	ip_up
	/sbin/wpa_supplicant -B -iwlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf -f/var/log/wap_supplicant.log
	wait $!
	ip addr flush dev wlan0
	
	# sleep on it. we need to make sure there is an ip before continuing
    gw_wlan0_ip=$(get_wlan0_ip)
	while [ "" == "$gw_wlan0_ip" ]; do
		set +x
	    gw_wlan0_ip=$(get_wlan0_ip)
		sleep 3;
	done
	set -x
	ns="nameserver $gw_wlan0_ip"
	if ! grep -e "$ns" /var/lib/rancher/turnkey/resolv.conf; then
		echo "nameserver $gw_wlan0_ip" >> /var/lib/rancher/turnkey/resolv.conf
		
		# Since this is a fresh update to the resolv.conf file, we will need to 
		# restart k3s
		K3S_PID=$(ps -eo pid,cmd | grep -E "k3s .*(server|agent)" | grep -E -v "(init|grep|channelserver)" | awk '{print $1}')
		kill $K3S_PID
	fi

	#
	gw_eth0_ip=$(ip r | grep -e "default" | grep -e "eth0" | awk '{print $3}')
	if [ "" != "$gw_eth0_ip" ]; then
		ip r del default via "$gw_eth0_ip" dev eth0
	fi

	set +x
	while true
	do
		sleep 10
	done
}

function scan()
{
	ip_up
	# Clear the ssid list before writing it out again
	printf '' > /tmp/ssid.list
	$(iwlist wlan0 scan | grep "ESSID" | sort | uniq | sed 's/\"//g' | awk -F: '{print $2}' >> /tmp/ssid.list)
	wait $!

	down
}

function reset()
{
	down
	wait $!
	up
}

trap down SIGTERM
trap reset SIGUSR1

"$@"
