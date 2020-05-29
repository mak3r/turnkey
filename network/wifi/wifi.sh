#!/bin/bash
set -x

while getopts h flag
do
    case "${flag}" in
        h) echo "wifi.sh [up|down|reset|scan|init]"
			exit 0
			;;
    esac
done

function init()
{
	# wpa_supplicant.conf must come from an external source
	cp /var/lib/rancher/turnkey/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
}

function ip_up()
{
	ip link set wlan0 up
	ip addr flush dev wlan0
}

function wifi_down()
{
    ip link set wlan0 down
}

function wifi_up()
{
	ip_up
	/sbin/wpa_supplicant -iwlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf -u -s
	while true
	do
		sleep 10
	done
}

function scan()
{
	ip_up
	# Clear the ssid list before writing it out again
	printf '' > /var/lib/rancher/turnkey/ssid.list
	$(iwlist wlan0 scan | grep "ESSID" | sort | uniq | sed 's/\"//g' | awk -F: '{print $2}' >> /var/lib/rancher/turnkey/ssid.list)
	wait $!

	wifi_down
}

function reset()
{
	init
	wifi_down
	wait $!
	wifi_up
}

trap wifi_down SIGTERM
trap reset SIGUSR1

if [ "$1" == "scan" ]
then
	scan
elif [ "$1" == "down" ]
then
	wifi_down
elif [ "$1" == "up" ]
then
	wifi_up
elif [ "$1" == "reset" ]
then
	reset
fi
