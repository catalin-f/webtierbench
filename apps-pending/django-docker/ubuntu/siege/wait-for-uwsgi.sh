#!/bin/bash

while ! netcat -w 5 10.10.10.11 8000; do
    sleep 3
done

echo "uWSGI is up and running!"
