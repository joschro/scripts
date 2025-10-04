#!/bin/sh

test -f 99-led-badge-44x11.rules || exit

sudo cp 99-led-badge-44x11.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

sudo dnf install hidapi python3-hidapi python3-pillow python3-pyusb
