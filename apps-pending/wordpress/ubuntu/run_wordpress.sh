#!/bin/sh

oss_dir="$HOME/oss-performance"

for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
	[ -f $CPUFREQ ] || continue
	echo -n performance > $CPUFREQ
done

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

su $SUDO_USER -c "cd $oss_dir; 					\
/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm"
