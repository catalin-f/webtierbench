FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                                            \
    && apt-get install -y git python3-virtualenv python3-dev  \
        python-pip libmemcached-dev zlib1g-dev netcat-openbsd \
    && mkdir /scripts                                         \
    && git clone https://github.com/Instagram/django-workload \
    && cd django-workload/django-workload                     \
    && git checkout 2600e3e784cb912fe7b9dbe4ebc8b26d43e1bacb  \
    && python3 -m virtualenv -p python3 venv                  \
    && . venv/bin/activate                                    \
    && pip install -r requirements.txt                        \
    && deactivate                                             \
    && cp cluster_settings_template.py cluster_settings.py

COPY wait-for-cassandra.sh uwsgi_init.sh /scripts/

ENV DEBIAN_FRONTEND teletype

CMD /scripts/wait-for-cassandra.sh && /scripts/uwsgi_init.sh uwsgi
