#!/bin/bash

oss_dir="/home/hhvmuser/oss-performance"

service mysql start
service nginx start

for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
	[ -f $CPUFREQ ] || continue
	echo -n performance > $CPUFREQ
done

echo 1 | tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

mysql -u root -e "USE mysql; UPDATE user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"

for (( i=1; i<=$ATTEMPTS; i++ ))
do
	su hhvmuser -c "echo '****************************************************';	\
	echo '*                  Test Run No $i                   *';			\
	echo '****************************************************';			\
	cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm"
done

service mysql stop
service nginx stop && tail -F /dev/null

