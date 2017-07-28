FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -m tester                                                    \
    && apt-get update                                                    \
    && apt-get -y install git siege python3 python3-numpy netcat-openbsd \
    && git clone https://github.com/Instagram/django-workload            \
        /home/tester/django-workload                                     \
    && cd /home/tester/django-workload/                                  \
    && git checkout f300654b1ba98aa649795b0af637f721dd6b2cd1             \
    && echo 'failures = 1000000' > /home/tester/.siegerc                 \
    && cd /home/tester/django-workload/client                            \
    && sed -i 's/localhost/$TARGET_ENDPOINT/g' urls_template.txt         \
    && ./gen-urls-file                                                   \ 
    && mkdir -p /home/tester/scripts

COPY wait-for-uwsgi.sh siege_init.sh /home/tester/scripts/

RUN chown -R tester:tester /home/tester \
    && echo "Write sysctl settings ...\n"\
    && echo "net.ipv4.tcp_tw_reuse=1\n\
net.ipv4.ip_local_port_range=1024 64000\n\
net.ipv4.tcp_fin_timeout=45\n\
net.core.netdev_max_backlog=10000\n\
net.ipv4.tcp_max_syn_backlog=12048\n\
net.core.somaxconn=1024\n\
net.netfilter.nf_conntrack_max=256000" >> /etc/sysctl.conf \
    && echo "Add nf_conntrack to modules ...\n"\
    && echo "nf_conntrack" >> /etc/modules \
    && echo "Add limits settings ...\n"\
    && echo "* soft nofile 1000000\n\
* hard nofile 1000000" >> /etc/security/limits.conf

ENV DEBIAN_FRONTEND teletype

CMD /home/tester/scripts/siege_init.sh
