#!/bin/bash

ADDRESS=http://${WEBTIER_IP}:${WEBTIER_PORT}/index.html
echo ${ADDRESS}
ab -n 10 -c 2 ${ADDRESS}