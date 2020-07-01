# Why Turnkey Devices
One of the issues for setting up branch operations is preparing the device for the site in such a way that it does not require a highly trained technician to be involved in installation, setup and configuration. In the past it was nearly unavoidable to have this done by sneaker net. The process would involve shipping a preconfigured system to a site and then, once it arrived, a specialist would come on premises for a day or sometimes a week or more to setup and configure the system. Updates/upgrades also required the sneaker net specialist.

Specialists might have expertise in networking or even be trained in the unique solution for configuration and maintenance.

Today, we can very simply ship a device which provides a turnkey solution that is simple enough for non-technical site owners and managers to use. The advent of home automation and smart devices has paved the way for expectations of simplicity in this manner. K3s and container orchestration provide a platform to deliver.


This repository hosts and example solution for delivering a small device to end-users who simply plug it in and provide credentials to their local network. In this example, we are creating and shipping a device whose end-user wants to have an easy to access edge kubernetes solution. The solution, when complete will provide 4 options for the end user:
1. Administrative access to a single node k3s cluster on the device
1. Admin access to a single node Rancher management server
1. Auto connection of this cluster to an existing Rancher management server.
1. Add an agent (worker node) to an existing k3s cluster


# Build
Bootstrapping the image can be challenging for a number of reasons. The device will need a network to start so that k3s can be installed. In the future, when k3s air-gap works on Arm, it should be possible to setup a device without any network.
## Setup - admins
This is a list of things which need to be done in order to bootstrap the system. The actual things which are being done for bootstrapping are in the [pre-config/setup.sh](pre-config/setup.sh) script
1. Install a raspbian buster lite image on an sdcard
1. Configure the system for k3s
	* Make sure cgroups is enabled in cmdline.txt add `cgroup_memory=1 cgroup_enable=memory`
1. Install k3s
Here are some recommended options
	* `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san raspberrypi --write-kubeconfig /home/pi/.kube/config --no-deploy servicelb --resolv-conf /var/lib/rancher/turnkey/resolv.conf" sh -`
	* The servicelb must be disabled
	* A host network must be available to kubernetes
1. Make sure there is a temporary network for k3s to startup
    * add this to `/etc/rc.local`
	```
	ip link set dev eth0 up
	ip addr add 192.168.1.1/24 brd 192.168.255.255 dev eth0
	route add default gw 192.168.1.1
    ```
1. Add 2 files to `/var/lib/rancher/k3s/server/manifests/`
	* [k8s/turnkey-ns.yaml](k8s/turnkey-ns.yaml)
	* [k8s/interactive-setup.yaml](k8s/interactive-setup.yaml) 
1. Configure a resolv.conf for kubernetes
	* `/var/lib/rancher/turnkey/resolv.conf`
	```
	domain lan
	nameserver 192.168.1.1
	```
1. Image the sd card for use in other devices

# Usage
1. When a device is shipped to the site
    1. plug it in
	1. turn it on 
	1. From another device (phone, computer, etc) connect to the AP
        * ssid: `ConfigureK3s`
        * passphrase: `rancher-k3s` 
    1. Navigate to `192.168.4.1` or `raspberrypi.lan`
1. Set your network credentials in the form and submit
    * When the device comes back up, it will have installed / deployed the selected configuration

# Caveats
* This is an example designed specificially for Raspberry Pi 4B devices running Raspbian with a 64bit kernel. It has not been tested as a generic solution for other OSes/devices.
* The device must have a wireless card/chip capable of entering AP mode

## Special thanks
* The UI was pulled from https://github.com/schollz/raspberry-pi-turnkey
