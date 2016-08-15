#!/bin/bash
docker run -h driver -u debian -d --name driver --volumes-from builder -v /Users/chrisk/source/docker-test/shared:/home/debian/shared -w /home/debian driver tail -f /dev/null
docker exec -it driver bash
