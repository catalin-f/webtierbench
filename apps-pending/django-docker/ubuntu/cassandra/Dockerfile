# Use ubuntu 16.04 image as a base OS
# Update apt repositories
# Install curl
# Add the java and cassandra repositories keys
# Add java and cassandra repositories
# Accept java license prompt
# Install java and cassandra

FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update                                                                     \
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
    && apt-get install -y oracle-java8-installer cassandra

ENV DEBIAN_FRONTEND teletype
