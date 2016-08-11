#!/bin/bash
docker run --link builder -h driver -u debian -d --name driver --volumes-from shared -w /home/debian/gitian-builder driver tail -f /dev/null
docker exec -it driver bash
