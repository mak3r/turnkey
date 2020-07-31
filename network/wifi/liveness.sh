#!/bin/sh
wlan0_ip=$(ip r | grep -e "default" | grep -e "wlan0" | awk '{print $3}')

# Check if the gateway accessible via the nic used
# do not assume the network beyond the gw is visible
ping -c 3 $wlan0_ip
