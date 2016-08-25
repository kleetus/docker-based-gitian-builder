#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker run -d -h cacher --name cacher \
-v $THISDIR/bitcoin:/shared/bitcoin \
cacher tail -f /dev/null &&
docker exec -it cacher /bin/bash
