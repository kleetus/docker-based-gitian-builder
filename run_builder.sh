#!/bin/bash
docker run -h builder -d --name builder --volumes-from shared builder &&
docker exec -it builder bash
