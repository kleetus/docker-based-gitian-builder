#!/bin/bash
docker run -h builder --name builder \
-v /home/k/source/docker-based-gitian-builder/cache:/shared/cache \
-v /home/k/source/docker-based-gitian-builder/result:/shared/result \
builder
