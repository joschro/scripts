#!/bin/sh

ip li sh | grep cni-podman0 || ip link add cni-podman0 type bridge
podman start pihole
podman ps
