#!/bin/sh

sudo dnf update -y
sudo dnf install @kde-desktop
sudo systemctl set-default graphical.target
sudo systemctl disable gdm
sudo systemctl enable sddm
reboot
