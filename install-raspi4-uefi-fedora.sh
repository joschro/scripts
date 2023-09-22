#!/bin/sh

# from https://fwmotion.com/blog/operating-systems/2020-09-05-installing-fedora-workstation-onto-pi4

# get kernel, kernel-core and kernel-modules from https://koji.fedoraproject.org/koji/packageinfo?packageID=8 and copy on /dev/sdb1
# ex. kernel-5.8.9-301.fc33 aarch64

# for eeprom: copy https://github.com/raspberrypi/rpi-eeprom/releases onto an empty vfat partition on an SD card

# F33 image: https://dl.fedoraproject.org/pub/fedora-secondary/development/33/Spins/aarch64/images/

test $# -lt 1 && echo "Syntax: $0 <image.raw.xz> [device-path]" && exit
origImg="$1"

myDEV=/dev/sdb
test $# -gt 1 && myDEV="$2"

sudo fdisk -l $myDEV
echo
echo -n "Are you SURE? (y/n) "; read ANSWER; test "$ANSWER" = "y" || exit

xzcat -c $origImg | dd of=./extracted-image.mbr bs=512 count=1
fdisk -l ./extracted-image.mbr > ./extracted-image.mbr.fdisk
cat ./extracted-image.mbr.fdisk

echo
echo " Going to \"sfdisk --delete $myDEV\""
echo -n "Are you SURE? (y/n) "; read ANSWER; test "$ANSWER" = "y" || exit
sudo flock $myDEV sfdisk --delete $myDEV
echo
echo " Going to apply the following partition table to $myDEV:"
cat <<EOF
2048 +128M c
- $(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n1 | tail -n1) 6 *
- $(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n2 | tail -n1)
- $(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n3 | tail -n1)
EOF
echo -n "Are you SURE? (y/n) "; read ANSWER; test "$ANSWER" = "y" || exit

sudo flock $myDEV cat <<EOF | sudo sfdisk $myDEV
2048 +128M c
- $(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n1 | tail -n1) 6 *
- $(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n2 | tail -n1)
- $(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n3 | tail -n1)
EOF

sudo mkfs.vfat -v -F 32 -n UEFI ${myDEV}1
sync
wget -O RPi4_UEFI_Firmware_v1.20.zip https://github.com/pftf/RPi4/releases/download/v1.20/RPi4_UEFI_Firmware_v1.20.zip
sudo mount ${myDEV}1 /mnt && sudo unzip RPi4_UEFI_Firmware_v1.20.zip -d /mnt/
ls -l /mnt/
sudo umount /mnt
echo

echo "Writing partitions to $myDEV ..."; echo
SKIP="$(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f2 | head -n1 | tail -n1)"
COUNT="$(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n1 | tail -n1)"
TARGET=${myDEV}2
echo "TARGET=$TARGET SKIP=$SKIP COUNT=$COUNT"
xzcat -c $origImg | sudo dd of=$TARGET ibs=512 skip=$SKIP count=$COUNT obs=4K seek=0 conv=nocreat,notrunc,sparse status=progress
echo

SKIP="$(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f2 | head -n2 | tail -n1)"
COUNT="$(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n2 | tail -n1)"
TARGET=${myDEV}3
echo "TARGET=$TARGET SKIP=$SKIP COUNT=$COUNT"
xzcat -c $origImg | sudo dd of=$TARGET ibs=512 skip=$SKIP count=$COUNT obs=4K seek=0 conv=nocreat,notrunc,sparse status=progress
echo

SKIP="$(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f2 | head -n3 | tail -n1)"
COUNT="$(fdisk -l -o Device,Start,Sectors ./extracted-image.mbr | grep "mbr[[:digit:]]" | tr -s " " | cut -d" " -f3 | head -n3 | tail -n1)"
TARGET=${myDEV}4
echo "TARGET=$TARGET SKIP=$SKIP COUNT=$COUNT"
xzcat -c $origImg | sudo dd of=$TARGET ibs=512 skip=$SKIP count=$COUNT obs=4K seek=0 conv=nocreat,notrunc,sparse status=progress
echo

sync;sync;sync
