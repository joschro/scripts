#!/bin/sh

alias docker=podman
docker run -d \
--name watchtower \
--restart=always \
--env "DOCKER_HOST=unix:///var/run/podman/podman.sock" \
containrrr/watchtower \
--cleanup --include-restarting


#-v /var/run/docker.sock:/var/run/docker.sock \
