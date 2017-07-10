#!/bin/bash

oss_dir="$HOME/oss-performance"

systemctl restart mysql.service
systemctl restart nginx.service

for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
	[ -f $CPUFREQ ] || continue
	echo -n performance > $CPUFREQ
done

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

for (( i=1; i<=$1; i++ ))
do
	su $SUDO_USER -c "echo '****************************************************';	\
	echo '*                  Test Run No $i                   *';			\
	echo '****************************************************';			\
	cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm"
done

systemctl stop mysql.service
systemctl stop nginx.service
