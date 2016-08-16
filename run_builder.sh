#!/bin/bash
docker run -h builder -d --name builder -v /Users/kleetus/source/docker-based-gitian-builder/shared:/tmp/shared builder &&
docker exec -it builder bash
