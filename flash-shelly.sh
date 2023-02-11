#!/bin/sh

test $# -lt 1 && exit

FLASH_FILE=$1
PORT_NAME=/dev/ttyUSB0
test $# -gt 1 && PORT_NAME=$2

BAUD="--baud 4800"
BAUD="--baud 115200"
BAUD=""
#BAUD="--baud 9600"

echo -n "To read chip ID,"
echo -n " reset by pressing the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && {
       esptool --port $PORT_NAME $BAUD chip_id || exit
}
echo -n "To backup firmware,"
echo -n " reset by pressing the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && {
	esptool --port $PORT_NAME $BAUD read_flash 0x00000 0x100000 Backup_1MB-$(date +"%Y-%M-%d-%H-%M-%S").bin || exit 
}
echo -n "To erase flash,"
echo -n " reset by pressing the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && {
	esptool --port $PORT_NAME $BAUD erase_flash || exit 
}
echo -n "To flash new firmware,"
echo -n " reset by pressing the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && esptool --port $PORT_NAME $BAUD write_flash --flash_size=4MB -fm dout 0x0 "$FLASH_FILE"
