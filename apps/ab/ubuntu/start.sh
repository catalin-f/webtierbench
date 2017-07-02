#!/bin/bash

address=http://${WEBTIER_IP}:${WEBTIER_PORT}/index.html
echo $address
ab -n 10 -c 2 $address