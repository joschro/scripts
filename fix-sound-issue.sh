#!/bin/sh

wpctl status

#systemctl restart wireplumber --user
systemctl --user restart wireplumber pipewire pipewire-pulse

wpctl status
