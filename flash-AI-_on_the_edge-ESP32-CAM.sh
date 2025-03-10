#!/bin/sh

echo "Download firmware from https://github.com/jomjol/AI-on-the-edge-device/releases/latest"
filesDir="."
test $# -gt 0 && filesDir="$1"
test -f "${filesDir}/bootloader.bin" || echo "${filesDir}/bootloader.bin not found"
test -f "${filesDir}/partitions.bin" || echo "${filesDir}/partitions.bin not found"
test -f "${filesDir}/firmware.bin" || echo "${filesDir}/firmware.bin not found"
zipFile="$(ls -1 ${filesDir}/AI-on-the-edge-device__manual-setup__v*.zip | tail -n1)"
test -f "$zipFile" || echo "AI-on-the-edge-device__manual-setup__v*.zip not found"
test -f "$zipFile" && unzip $zipFile -d ${filesDir}/
test -f "${filesDir}/bootloader.bin" -a -f "${filesDir}/partitions.bin" -a -f "${filesDir}/firmware.bin" && {
	esptool erase_flash
	esptool write_flash 0x01000 ${filesDir}/bootloader.bin 0x08000 ${filesDir}/partitions.bin 0x10000 ${filesDir}/firmware.bin
}
