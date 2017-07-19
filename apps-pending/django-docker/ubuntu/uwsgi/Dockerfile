FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                                            \
    && apt-get install -y git python3-virtualenv python3-dev  \
        python-pip libmemcached-dev zlib1g-dev                \
    && mkdir /scripts                                         \
    && git clone https://github.com/Instagram/django-workload \
    && cd django-workload/django-workload                     \
    && git checkout b18dace0491051ba85b5fed908db8a92adb2f2ae  \
    && python3 -m virtualenv -p python3 venv                  \
    && . venv/bin/activate                                    \
    && pip install -r requirements.txt                        \
    && deactivate                                             \
    && cp cluster_settings_template.py cluster_settings.py

COPY uwsgi_init.sh /scripts

ENV DEBIAN_FRONTEND teletype

CMD /scripts/uwsgi_init.sh
