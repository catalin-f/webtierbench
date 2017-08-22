#!/bin/bash

oss_dir="$HOME/oss-performance"
siege_log="$HOME/siege.log"

service mysql start
systemctl restart nginx.service

if [ -f "$siege_log" ]; then
	rm -rf $siege_log
fi

for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
	[ -f $CPUFREQ ] || continue
	echo -n performance > $CPUFREQ
done

sudo echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

mysql -u root -e "USE mysql; UPDATE user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"

if ! [ -d "/tmp/logs" ]; then
	mkdir /tmp/logs
fi

su $SUDO_USER -c "cp -f cplog.sh $oss_dir"

for (( i=1; i<=$1; i++ ))
do
	su $SUDO_USER -c "echo '****************************************************';	\
	echo '*                  Test Run No $i                   *';			\
	echo '****************************************************';			\
	cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm --db-username root --db-password '' --i-am-not-benchmarking --temp-dir /tmp/logs --exec-after-benchmark ./cplog.sh"
done

service mysql stop
systemctl stop nginx.service
