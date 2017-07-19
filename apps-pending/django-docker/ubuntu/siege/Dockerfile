FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                                                \
    && mkdir /scripts                                             \
    && apt-get -y install git siege python3                       \
    && git clone https://github.com/Instagram/django-workload.git \
    && cd django-workload/                                        \
    && git checkout b18dace0491051ba85b5fed908db8a92adb2f2ae      \
    && echo 'failures = 1000000' > .siegerc

COPY siege_init.sh /scripts/

ENV DEBIAN_FRONTEND teletype

CMD /scripts/siege_init.sh
