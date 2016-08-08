#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker run -d -h builder --name builder \
-v $THISDIR/cache:/shared/cache \
-v $THISDIR/result:/shared/result \
builder tail -f /dev/null &&
docker exec -it builder /bin/bash
