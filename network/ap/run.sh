#!/bin/sh

docker run -it --rm --privileged --net=host --name hostapd mak3r/hostapd:simple
