#!/bin/bash
docker create -u debian -v /shared --name shared debian:stable /bin/true
