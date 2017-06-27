#!/bin/bash

set -xe

docker build -t demo_nginx_mysql .
docker run -v `pwd`:/usr/src/app/ -t demo_nginx_mysql

