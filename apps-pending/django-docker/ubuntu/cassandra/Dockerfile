# Use ubuntu 16.04 image as a base OS
FROM ubuntu:16.04

# Update our apt index and install curl
RUN apt-get update && apt-get install -y curl

# Add the java repository key
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xC2518248EEA14886

# Download cassandra keys
RUN curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -

# Add java repository
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" \
> /etc/apt/sources.list.d/webupd8team-ubuntu-java-xenial.list

RUN echo "deb http://www.apache.org/dist/cassandra/debian 310x main" | \
tee -a /etc/apt/sources.list.d/cassandra.sources.list

# Accept java license prompt
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Install java
RUN apt-get update && apt-get install -y oracle-java8-installer

# Install cassandra
RUN apt-get install -y cassandra
