# Why Turnkey Devices
One of the issues for managing branch operations is the initial preparation of the device for the site. In the past this was often done by sneaker net. The process would involve shipping hardware to a site and then, once it arrived, a specialist would come on premises for a day or sometimes a week to setup and configure the system. Any future Updates/upgrades/management also required the sneaker net specialist.

What if we could simply ship a device which provides the branch owner to simply plug it in. The turnkey project demonstrates how we can do this. An end user can plug in, turn on and then provide minimal credentials and any other minimal details which can then be used as a basis for configuration. These devices can phone home for configuration and even be configured for central management from a remote location.

# Basic usage
## Setup - admins
1. Install k3s
1. Add [k8s/interactive-setup.yaml] to the manifest directory
1. Image the sd card for use in other devices

## Users
1. When a device is shipped to the site
    1. plug it in
	1. From another device (phone, computer, etc) connect to the AP
        * ssid: `ConfigureK3s`
        * passphrase: `rancher-k3s` 
    1. Navigate to `192.168.4.1` or `raspberrypi.lan`
1. Set your network credentials in the form and submit
    * When the device comes back up, it will have installed / deployed the selected configuration

# Current todo list:
1. docs
1. configure the process which takes place after the user selects their network and submits the form
1. cleanup/remove message at the top of the UI about snaptext.live
1. burn the current image with k3s on it
1. 

## Caveats
* This is an example designed specificially for Raspberry Pi 4B devices running Raspbian with a 64bit kernel. It has not been tested as a generic solution for other OSes/devices.
* device must have a wireless card/chip capable of entering AP mode

## Special thanks
* The UI was pulled from https://github.com/schollz/raspberry-pi-turnkey
