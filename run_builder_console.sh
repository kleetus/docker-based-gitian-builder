#!/bin/bash
docker run -d -h builder --name builder \
-v /home/k/source/docker-based-gitian-builder/cache:/shared/cache \
-v /home/k/source/docker-based-gitian-builder/result:/shared/result \
builder tail -f /dev/null &&
docker exec -it builder /bin/bash
