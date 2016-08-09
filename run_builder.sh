#!/bin/bash
docker run --link driver -h builder -d --name builder --volumes-from shared builder &&
docker exec -it builder bash
