#!/bin/sh
if ! ip addr show wlan0 | grep -w "inet"; then
	exit 1;
else
	exit 0;
fi
