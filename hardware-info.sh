#!/bin/sh

type dmidecode >/dev/null || sudo dnf install lshw dmidecode -y
type lshw >/dev/null || sudo dnf install lshw dmidecode -y

sudo dmidecode | grep -A3 'Vendor:\|Product:' && sudo lshw -C cpu | grep -A3 'product:\|vendor:'
