#!/bin/bash

oss_dir="$HOME/oss-performance"

service mysql start
systemctl restart nginx.service

for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
	[ -f $CPUFREQ ] || continue
	echo -n performance > $CPUFREQ
done

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

mysql -u root -e "USE mysql;"
mysql -u root -e "UPDATE user SET plugin='mysql_native_password' WHERE User='root';"
mysql -u root -e "FLUSH PRIVILEGES;"

for (( i=1; i<=$1; i++ ))
do
	su $SUDO_USER -c "echo '****************************************************';	\
	echo '*                  Test Run No $i                   *';			\
	echo '****************************************************';			\
	cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm"
done

service mysql stop
systemctl stop nginx.service
