#!/bin/sh

docker run -it --run --privileged --net=host -v /tmp:/var/lib/rancher/turnkey mak3r/wifi:local
