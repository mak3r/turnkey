FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y dnsmasq dhcpcd5 hostapd nftables iproute2
RUN rm /etc/dnsmasq.conf /etc/dhcpcd.conf; \
  ln -s /conf/dnsmasq.conf /etc/dnsmasq.conf; \
  ln -s /conf/dhcpcd.conf /etc/dhcpcd.conf; \
  ln -s /conf/hostapd.conf /etc/hostapd/hostapd.conf

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ADD liveness.sh /usr/local/bin/liveness.sh

WORKDIR /root

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["down"]