FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -m hhvmuser && echo "hhvmuser:123456" | chpasswd && adduser hhvmuser sudo

COPY check_oss.sh /home/hhvmuser
COPY install_oss.sh /home/hhvmuser
COPY run_wordpress.sh /home/hhvmuser

RUN chown -R hhvmuser:hhvmuser /home/hhvmuser

RUN apt-get update && apt-get install -y	\
	build-essential				\
	git					\
	make					\
	software-properties-common		\
	util-linux				\
	wget

RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN add-apt-repository "deb http://dl.hhvm.com/ubuntu xenial main"

RUN apt-get update && apt-get install -y 	\
	nginx					\
	unzip					\
	mariadb-server				\
	coreutils				\
	autotools-dev				\
	autoconf				\
	hhvm

RUN cd /home								\
	&& wget http://download.joedog.org/siege/siege-2.78.tar.gz	\
	&& tar xzf siege-2.78.tar.gz					\
	&& cd siege-2.78/						\
	&& ./configure							\
	&& make								\
	&& make install

ENV DEBIAN_FRONTEND teletype
RUN su hhvmuser -c /home/hhvmuser/install_oss.sh

RUN service mysql stop
RUN service nginx stop

CMD /home/hhvmuser/run_wordpress.sh
