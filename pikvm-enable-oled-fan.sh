#!/bin/sh

systemctl enable --now kvmd-oled kvmd-oled-reboot kvmd-oled-shutdown
systemctl enable --now kvmd-fan
