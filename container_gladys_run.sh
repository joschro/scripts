#!/bin/sh

alias docker=podman
sudo mkdir -p /var/lib/gladysassistant && sudo chown $USER:$USER /var/lib/gladysassistant

docker run -d \
--log-driver json-file \
--log-opt max-size=10m \
--cgroupns=host \
--restart=always \
--privileged \
--network=host \
--name gladys \
-e NODE_ENV=production \
-e SERVER_PORT=8080 \
-e TZ=Europe/Berlin \
-e SQLITE_FILE_PATH=/var/lib/gladysassistant/gladys-production.db \
--env "DOCKER_HOST=unix:///var/run/podman/podman.sock" \
-v /var/lib/gladysassistant:/var/lib/gladysassistant \
-v /dev:/dev \
-v /run/udev:/run/udev:ro \
gladysassistant/gladys:latest


# -v /var/run/podman.sock:/var/run/docker.sock \
