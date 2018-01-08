#!/bin/bash

#remove exists images
docker stop eolinker_os
docker rm eolinker_os
docker rmi eolinker/eolinker_os

#rebuild docker image
docker build -t eolinker/eolinker_os ./
