#!/bin/bash
docker run -h builder -d --name builder -v /pubkey -v /privkey builder &&
docker exec -it builder bash
