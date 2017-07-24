FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                                                \
    && mkdir /scripts                                             \
    && apt-get -y install git siege python3                       \
    && git clone https://github.com/Instagram/django-workload.git \
    && cd django-workload/                                        \
    && git checkout f300654b1ba98aa649795b0af637f721dd6b2cd1      \
    && echo 'failures = 1000000' > .siegerc

COPY siege_init.sh /scripts/

ENV DEBIAN_FRONTEND teletype

CMD /scripts/siege_init.sh
