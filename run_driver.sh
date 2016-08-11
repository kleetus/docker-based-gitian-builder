#!/bin/bash
docker run --link builder -h driver -u debian -d --name driver --volumes-from shared -w /home/debian/gitian-builder driver /home/debian/runit.sh v0.12.1-bitcore-2 https://github.com/bitpay/bitcoin.git
