FROM arm64v8/debian:buster

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y dnsmasq dhcpcd hostapd iptables

ADD ap.sh /bin/ap.sh

ENTRYPOINT [ "/bin/ap.sh" ]
