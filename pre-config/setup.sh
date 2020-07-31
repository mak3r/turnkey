#!/bin/bash -x

function usage() {
      echo "Usage: $0 [bhr] "
	  echo -e "\t-b git-branch\tPull content from the git branch specified."
	  echo -e "\t\t\tUses the master branch by default."
	  echo -e "\t-h\t\tHelp."
	  echo -e "\t-r\t\tRestart when script is complet."
}

export TURNKEY_BRANCH="master"
RESTART="0"
while getopts "b:hr" opt; do
  case $opt in
    b)
      TURNKEY_BRANCH=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    r)
      RESTART="1"
	  ;;
    \?)
      usage
	  exit 0
      ;;
  esac
done

#don't re-run this block if it's been done before
if [[ ! -f /etc/rc.local.orig ]]; then
	cp /etc/rc.local /etc/rc.local.orig
	sed -i.bak '0,/^exit 0/s/^exit 0/ip link set dev eth0 up\n&/' /etc/rc.local
	sed -i.bak '0,/^exit 0/s/^exit 0/ip addr add 192\.168\.1\.1\/24 brd 192\.168\.255\.255 dev eth0\n&/' /etc/rc.local
	sed -i.bak '0,/^exit 0/s/^exit 0/route add default gw 192\.168\.1\.1\n&/' /etc/rc.local
fi

mkdir -p /var/lib/rancher/turnkey
curl -L "https://raw.githubusercontent.com/mak3r/turnkey/$TURNKEY_BRANCH/pre-config/resolv.conf" -o /var/lib/rancher/turnkey/resolv.conf
curl -L "https://raw.githubusercontent.com/mak3r/turnkey/$TURNKEY_BRANCH/pre-config/turnkey-reset.sh" -o /usr/local/bin/turnkey-reset.sh
chmod +x /usr/local/bin/turnkey-reset.sh
curl -L "https://raw.githubusercontent.com/mak3r/turnkey/$TURNKEY_BRANCH/pre-config/turnkey-reset.service" -o /etc/systemd/system/turnkey-reset.service
systemctl enable turnkey-reset.service
curl -L "https://raw.githubusercontent.com/mak3r/turnkey/$TURNKEY_BRANCH/k8s/turnkey-ns.yaml" -o /var/lib/rancher/turnkey/turnkey-ns.yaml
curl -L "https://raw.githubusercontent.com/mak3r/turnkey/$TURNKEY_BRANCH/k8s/interactive-setup.yaml" -o /var/lib/rancher/turnkey/interactive-setup.yaml

# Remove turnkey process communication files
if [ -f /tmp/status ]; then
	rm /tmp/status
fi
if [ -f /tmp/ssid.list ]; then
	rm /tmp/ssid.list
fi

# remove any prior installation of k3s
/usr/local/bin/k3s-uninstall.sh

# install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san raspberrypi --write-kubeconfig /home/pi/.kube/config --no-deploy servicelb --resolv-conf /var/lib/rancher/turnkey/resolv.conf" sh -

wait $!
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"


cp /var/lib/rancher/turnkey/turnkey-ns.yaml /var/lib/rancher/k3s/server/manifests/turnkey-ns.yaml
cp /var/lib/rancher/turnkey/interactive-setup.yaml /var/lib/rancher/k3s/server/manifests/interactive-setup.yaml

# ideally we could detect when the turnkey images have finished downloading
# or better yet, resolve with air-gap installation 
# https://github.com/rancher/k3s/issues/1285
images=("busybox" "pause" "coredns" "traefik" "klipper-helm" "local-path-provisioner" "metrics-server" "turnkey-ui" "wifi" "hostapd")
for img in ${images[@]}; do
	echo "verifying $img is installed"
	while ! crictl images | grep -e $img; do
		sleep 10
	done
done

# remove turnkey yaml for image prep
rm /var/lib/rancher/k3s/server/manifests/interactive-setup.yaml
kubectl delete job -n turnkey hostapd
wait $!
kubectl delete job -n turnkey ui
wait $!

## prepare to load turnkey back in
systemctl stop k3s
rm /tmp/ssid.list
rm /tmp/status

# move turnkey yaml back in prior to reboot
cp /var/lib/rancher/turnkey/interactive-setup.yaml /var/lib/rancher/k3s/server/manifests/interactive-setup.yaml

echo "Image is prepped."


if [[ "1" == "$RESTART" ]]; then
	reboot now
fi
