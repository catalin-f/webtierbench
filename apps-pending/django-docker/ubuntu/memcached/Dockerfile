FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                  \
    && apt-get -y install memcached \
    && mkdir scripts

COPY memcached_init.sh memcached.cfg /scripts/

ENV DEBIAN_FRONTEND teletype

CMD /scripts/memcached_init.sh
