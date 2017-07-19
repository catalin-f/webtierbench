FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                                                                     \
    && mkdir /scripts                                                                  \
    && apt-get install -y curl                                                         \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xC2518248EEA14886 \
    && curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -                 \
    && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"         \
        > /etc/apt/sources.list.d/webupd8team-ubuntu-java-xenial.list                  \
    && echo "deb http://www.apache.org/dist/cassandra/debian 310x main"                \
        > /etc/apt/sources.list.d/cassandra.sources.list                               \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true"   \
        | debconf-set-selections                                                       \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true"     \
        | debconf-set-selections                                                       \
    && apt-get update                                                                  \
    && apt-get install -y net-tools oracle-java8-installer cassandra

COPY init_config.sh /scripts

RUN /scripts/init_config.sh

ENV DEBIAN_FRONTEND teletype

CMD service cassandra start \
    && tail -f /dev/null
