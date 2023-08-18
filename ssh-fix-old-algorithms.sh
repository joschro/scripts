#!/bin/sh

sudo echo "HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedAlgorithms +ssh-rsa" >> /etc/ssh/ssh_config

echo
echo "Use: ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o Ciphers=+aes256-cbc user@ip"
