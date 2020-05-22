#!/bin/sh

docker run -it --rm -v /tmp:/var/lib/rancher/turnkey -p 80:80 --name ui mak3r/turnkey-ui:local
