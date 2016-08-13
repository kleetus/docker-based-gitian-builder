#!/bin/bash

docker build -t driver --force-rm=true -f ./Dockerfile.driver .
