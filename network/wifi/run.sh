#!/bin/sh

docker run -it --rm --privileged --net=host -v /tmp:/var/lib/rancher/turnkey --name wifi mak3r/wifi:local
