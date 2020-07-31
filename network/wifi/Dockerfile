FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y wpasupplicant wireless-tools iproute2 procps iputils-ping

ADD wifi.sh /bin/wifi.sh
ADD liveness.sh /usr/local/bin/liveness.sh
ADD readiness.sh /usr/local/bin/readiness.sh
RUN chmod +x /usr/local/bin/*.sh
WORKDIR /app
VOLUME [ "/var/lib/rancher/turnkey" ]

ENTRYPOINT [ "/bin/wifi.sh" ]

CMD ["scan"]