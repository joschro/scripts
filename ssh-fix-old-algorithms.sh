#!/bin/sh

grep 'PubkeyAcceptedAlgorithms +ssh-rsa' /etc/ssh/ssh_config || sudo sh -c "echo -e 'HostKeyAlgorithms +ssh-rsa\nPubkeyAcceptedAlgorithms +ssh-rsa' >> /etc/ssh/ssh_config"

echo
echo "Use: ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o Ciphers=+aes256-cbc user@ip"
