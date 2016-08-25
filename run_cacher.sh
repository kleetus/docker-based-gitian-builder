#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker run -d -h cacher --name cacher \
-v $THISDIR/bitcoin:/shared/bitcoin \
cacher &&
docker exec -it cacher /bin/bash
