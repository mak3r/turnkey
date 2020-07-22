FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y wpasupplicant wireless-tools iproute2 procps

ADD wifi.sh /bin/wifi.sh
WORKDIR /app
VOLUME [ "/var/lib/rancher/turnkey" ]

ENTRYPOINT [ "/bin/wifi.sh" ]

CMD ["scan"]