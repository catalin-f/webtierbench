#!/bin/bash

while ! netcat -w 5 10.10.10.10 9042; do
    sleep 3
done

echo "Cassandra is up and running!"
