# Wordpress deployment

This directory contains necessary docker file and scripts that you can use to interact with Wordpress

## Pull wordpress image from our docker repository

sudo docker pull rinftech/webtierbench:wordpress-webtier

## Run Benchmark

docker run -e ATTEMPTS='<no_attempts>' wordpress-webtier:latest

