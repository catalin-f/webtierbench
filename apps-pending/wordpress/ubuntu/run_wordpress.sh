#!/bin/sh

oss_dir="$HOME/oss-performance"

for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
	echo "performance" > "$file"
done

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
sudo find /var/log/nginx -type f -exec chmod ug+rw {} \;

cd "$oss_dir"
/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm
