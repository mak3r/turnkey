# Overview
This repository hosts an example solution for delivering a turnkey device to end-users who simply plug it in and provide credentials to their local network. In this example, we are simply offering easy to access to a kubernetes cluster. The solution, when complete will provide 4 options for the end user:
1. Administrative access to a single node k3s cluster on the device (the [MVP release](https://github.com/mak3r/turnkey/releases/tag/v0.1.0-mvp))
1. Admin access to a single node Rancher management server (WIP)
1. Auto connection of this cluster to an existing Rancher management server (WIP)
1. Add an agent (worker node) to an existing k3s cluster (WIP)

# Why Turnkey Devices
One of the common issues branch operations, factories, retail and the far edge have with edge solutions is how to prepare the device(s) in such a way that they do not require a highly trained technician to be involved in installation, setup and configuration. In the past it was nearly unavoidable to have this done by sneaker net. The process would involve shipping a base system to a site and then, once it arrived, a specialist would come on premises for a day or sometimes a week or more to setup and configure the system. Updates/upgrades also required the sneaker net specialist.

Today, consumers have become used to receiving devices which they simply use, with minimal setup from a phone app or device local website. Occasionally a user might be asked to do a firmware or security update. These updates could be done remotely without the consumer ever knowing save for privacy concerns. Under the hood, these are still very complex hardware and software solutions. 

Enterprises with edge operations can maintain their robust software lifecycles for edge appliances while delivering the package in a turnkey manner. The idea is to provide a system in a box that is simple enough for non-technical site owners and managers to install and use while allowing the central IT department to host and manage it's updates, upgrades and features all remotely. 

The advent of home automation and smart devices has paved the way for expectations of simplicity in this manner. K3s and container orchestration provide a platform to deliver a turnkey solution that is easily installed and upgraded while being also remotely manageable and customizable.

# Build
Bootstrapping the image can be challenging for a number of reasons. Unless you are using one of the release images, the system will need to be internet connected to get setup. Since this particular solution is fundamentally based on managing the network interfaces from containers that are managed by k3s, automatic network connections will need to be disabled. 

## Setup - admins
This is a list of things which need to be done in order to bootstrap the system. 
### First, the OS needs to be prepped
1. Install a raspbian buster lite image on an sdcard
1. Configure the system for k3s
	* Make sure cgroups is enabled in cmdline.txt add `cgroup_memory=1 cgroup_enable=memory`
1. Disable automatic network connections
    * on raspbian e.g. `sudo systemctl stop wpa_supplicant.service`

### With a prepped OS, install k3s and the turnkey components
The exact steps which are being done for bootstrapping are in the [pre-config/setup.sh](pre-config/setup.sh) script. Here is a rough outline
1. Temporarily configure internet access. I used ethernet with dhcp
1. Install k3s
    Here are some recommended options:
	* `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san raspberrypi --write-kubeconfig /home/pi/.kube/config --no-deploy servicelb --resolv-conf /var/lib/rancher/turnkey/resolv.conf" sh -`
	* The servicelb must be disabled
	* A host network must be available to kubernetes
1. Make sure there is a temporary network for k3s to startup
    * One way to do this is to add this to `/etc/rc.local`
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
1. Stop k3s `sudo systemctl stop k3s`
1. Image the sd card for use in other devices

# Usage
1. plug it in
1. On a phone or computer connect to the `ConfigureK3s` network 
1. Navigate to `192.168.4.1` 
1. Set your network credentials in the form

## Reset
You can reset the device by dropping an empty file named `turnkey-reset` on the boot volume. The reset will clear the WiFi SSID list and credentials used and setup the containers for the basic turnkey usage again.

# Caveats
* This is an example designed specificially for Raspberry Pi 4B devices running Raspbian with a 64bit kernel. It has not been tested as a generic solution for other OSes/devices.
* The device must have a wireless card/chip capable of entering AP mode
* The project is configured such that the wifi network is always managed by kubernetes
	* it is possible to pass the network configuration to the host so it becomes permanent - it's just not done in this example
	* this example assumes an end user might want to demo this on different wifi networks repeatedly
* Assumptions about NIC naming are hardcoded throughout

### Special thanks
* The UI was originally pulled from https://github.com/schollz/raspberry-pi-turnkey

