FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y python3-flask python3-requests

WORKDIR /app
ADD startup.py /app/startup.py

ENTRYPOINT [ "/usr/bin/python3" ]

CMD [ "/app/startup.py" ]
