#!/bin/sh
if ! ip addr show wlan0 | grep -e "inet"; then
	exit 1;
else
	exit 0;
fi
