#!/bin/sh

ping -q -w 10 -c 3 192.168.178.1 >/dev/null || systemctl restart NetworkManager.service
