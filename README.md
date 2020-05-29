# Why Turnkey Devices
One of the issues for setting up branch operations is preparing the device for the site. In the past this was often done by sneaker net where the process would involve shipping hardware to a site and then, once it arrived, a specialist would come on premises for a day or sometimes a week to setup and configure the system. Updates/upgrades also required the sneaker net specialist.

What if we could simply ship a device the provides the site owner to simply plug it in and provide minimal credentials to a network and a site id. After that, the system should configure itself.

Today we can.

# Basic usage
1. Install k3s
1. Add [k8s/interactive-setup.yaml] to the manifest directory
1. Image the sd card for use in other devices
1. When a device is shipped to the site
    1. plugin
    1. connect to the AP
        * ssid: `ConfigureK3s`
        * passphrase: `rancher-k3s` 
1. Set your network credentials

# Current todo list:
1. docs
2. setup hostapd as non-privileged container - seems to be an issue with just using NET_ADMIN
    * perhaps debug by setting privileged off but adding all capabilities (so far the chosen list has not worked)
3. configure the process which takes place after the user selects their network
4. cleanup/remove message at the top of the UI about snaptext.live
5. burn the current image with k3s on it

# Caveats
* This is an example designed specificially for Raspberry Pi 4B devices running Raspbian with a 64bit kernel. It has not been tested as a generic solution for other OSes/devices.


