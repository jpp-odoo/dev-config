#! /bin/bash

## Up the DB and nginx
docker compose up -d

## Build the dockerfiles (find a way to do it automatically ?)
## For ARM-64
# docker build ....  bookworm ...

docker build -f images/trixie.dockerfile -t trixie .
docker build -f images/trixie-vnc.dockerfile -t trixie-vnc .
