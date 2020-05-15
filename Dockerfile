FROM arm64v8/debian:buster

ENTRYPOINT [ "systemctl" ]

CMD [ "list-unit-files" ]