#!/bin/sh

oss_dir=~/oss-performance

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
sudo find /var/log/nginx -type f -exec chmod ug+rw {} \;

cd "$oss_dir"
/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm
