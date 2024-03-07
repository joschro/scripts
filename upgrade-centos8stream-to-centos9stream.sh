#!/bin/sh

test -f /updated || {
# Update OS
dnf update -y && touch /updated
# Reboot system if there were any updates
reboot
}
test -f /updated && rm -f /updated
# Disable CentOS 8-specific modules (they are blocking kernel updates)
dnf module disable python36 virt
# Install CentOS 9 repositories. All CentOS 9 packages are listed here
dnf install https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-release-9.0-22.el9.noarch.rpm https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-22.el9.noarch.rpm https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-22.el9.noarch.rpm
# Run command to switch packages:
dnf --releasever=9 --allowerasing --setopt=deltarpm=false distro-sync -y
# Rebuild RPM database (this will chnage the backend to sqlite):
rpm --rebuilddb
# Disable subscription manager. Open file /etc/yum/pluginconf.d/subscription-manager.conf and set enabled to 0

# Reboot and verify

cat /etc/redhat-release
# Verify that the latest kernel is used (5.14+)
uname -a
# If not, use grubby to set the latest kernel as the default one, reboot the system and remove old kernels from CentOS 8:

# List all boot options
grubby --info=ALL

# Reflect the desired kernel in configuration
grubby --set-default vmlinuz-<version>.<arch>

# Make sure the index is also set in `/etc/default/grub` file

# Regenerate boot configuration
grub2-mkconfig -o /boot/grub2/grub.cfg

reboot

# Remove old kernels...
