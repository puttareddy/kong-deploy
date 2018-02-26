FROM kong:0.11-alpine

COPY kong.sh /kong.sh
COPY common /common

RUN mkdir -p /usr/local/kong

CMD kong start
