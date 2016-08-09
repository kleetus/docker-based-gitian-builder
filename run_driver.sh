#!/bin/bash
docker run --link builder -h driver -u debian -d --name driver --volumes-from shared -v $HOME/source/gitian-builder:/home/debian/gitian-builder -v $HOME/source/bitcoin:/home/debian/bitcoin -w /home/debian/gitian-builder driver bash -c 'sudo /home/debian/copy_keys && tail -f /dev/null' &&
docker exec -it driver bash
