#!/bin/bash

apt-get update
pip install -r requirements.txt

#if reboot is required
touch /tmp/.host.reboot.required