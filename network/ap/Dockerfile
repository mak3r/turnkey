FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y dnsmasq dhcpcd5 hostapd iptables iproute2

ADD ap.sh /bin/ap.sh

ENTRYPOINT [ "/bin/ap.sh" ]

CMD ["down"]