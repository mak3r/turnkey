#!/bin/bash


# remove turnkey yaml for image prep
rm /var/lib/rancher/k3s/server/manifests/interactive-setup.yaml
kubectl delete job -n turnkey hostapd --wait
kubectl delete job -n turnkey ui --wait

# remove turnkey yaml for wifi
rm /var/lib/rancher/k3s/server/manifests/wifi.yaml
kubectl delete deployment -n turnkey wifi --wait

# remove wifi credentials
rm /var/lib/rancher/k3s/server/manifests/connect-wifi.yaml

## prepare to load turnkey back in
systemctl stop k3s
rm /tmp/ssid.list
rm /tmp/status
rm -r /var/lib/rancher/k3s/server/db

# move turnkey yaml back in prior to reboot
cp /var/lib/rancher/turnkey/interactive-setup.yaml /var/lib/rancher/k3s/server/manifests/interactive-setup.yaml

# reset resolv.conf
cat <<- EOF > /var/lib/rancher/turnkey/resolv.conf 
	domain lan
	nameserver 192.168.1.1
EOF

(. /etc/rc.local)

# take down dev wlan0
ip addr flush dev wlan0
ip link set dev wlan0 down

sleep 5

systemctl start k3s