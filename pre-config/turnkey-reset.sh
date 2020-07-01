#!/bin/bash

CLEAN="0"
while getopts "c" opt; do
  case $opt in
    c)
      CLEAN="1"
      ;;
    h)
      echo "Usage: $0 \[-c\] "
      exit 0;
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Attempt to use kubectl to cleanup kubernetes
kubectl delete deployment -n turnkey wifi
kubectl delete job -n turnkey hostapd
kubectl delete job -n turnkey ui
wait $!
systemctl stop k3s
# Remove generated manifests
rm /var/lib/rancher/k3s/server/manifests/connect-wifi.yaml
rm /var/lib/rancher/k3s/server/manifests/wifi.yaml
# Remove the k3s database (expects single node k3s install)
rm -r /var/lib/rancher/k3s/server/db
# Remove process communication files
rm /tmp/status
rm /tmp/ssid.list
# remove default turnkey deployment manifests
rm /var/lib/rancher/k3s/server/manifests/interactive-setup.yaml
rm /var/lib/rancher/k3s/server/manifests/turnkey-ns.yaml


if [ "1" == "$CLEAN" ]; then 
  # remove existing containers
  # WARN: the system will need network connectivity 
  # or sneakernet to get these images back
  rm -r /var/lib/rancher/k3s/agent/containerd
fi

