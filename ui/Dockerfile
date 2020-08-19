FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y python3-flask python3-requests python3-pip wpasupplicant
RUN pip3 install PyYAML

WORKDIR /app
ADD startup.py /app/startup.py
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ADD templates /app/templates
ADD static /app/static
ADD wpa_supplicant /app/wpa_supplicant
ADD action /app/action
VOLUME [ "/tmp" ]
VOLUME [ "/var/lib/rancher/turnkey" ]
VOLUME [ "/var/lib/rancher/k3s/server/manifests" ]
ENV FLASK_ENV development

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

EXPOSE 80