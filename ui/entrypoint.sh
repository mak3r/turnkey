#!/bin/bash
set -x
/usr/bin/python3 /app/startup.py &
UIPID="$!"

while [ "down" != "$(cat /var/lib/rancher/turnkey/status)" ]; do
	set +x
	sleep 2
done

set -x
kill -9 "$UIPID"
wait $!

exit 0