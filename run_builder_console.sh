#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker run -it -h builder --name builder \
-v $THISDIR/cache:/shared/cache \
-v $THISDIR/result:/shared/result \
-e "COMMIT=v0.12.1-bitcore-4" \
-e "URL=https://github.com/bitpay/bitcoin" \
-e "CONFIG=/shared/bitcoin/contrib/gitian-descriptors/gitian-osx.yml" \
--entrypoint=/bin/bash \
builder -s
