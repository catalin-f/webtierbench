# Docker containers setup files

This directory contains all docker files and all necessary dependencies to build a docker image
with a particular service completely configured. Each application has it's dedicated directory.

## Build a docker image

To build a docker image with a particular service installed, go on the associated directory of
the service that you want to add to the image (for example memcached) and run the following command:

*docker build --no-cache -t <image_name> .*

[Do not forget the dot at the end]

You can check if the image has been built successfully with the following command:

*docker images*

## Push a docker image to our docker repository

Our docker repository is the following: https://hub.docker.com/r/rinftech/webtierbench/

In order to push a built image to our repository, run the following commands:

*docker login* [Use the credentials associated with your docker cloud account]

*docker tag <image_name> rinftech/webtierbench:<image_tag>*

*docker push rinftech/webtierbench:<image_tag>*
