#!/bin/sh

docker run -it --privileged -v /run:/run -v /run/lock:/run/lock  -v /tmp:/tmp -v /sys/fs/cgroup/systemd:/sys/fs/cgroup/systemd -v /var/lib/journal:/var/lib/journal mak3r/systemctl:simple