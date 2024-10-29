#!/bin/sh

test $# -lt 1 && exit

FLASH_FILE=$1
PORT_NAME=/dev/ttyUSB0
test $# -gt 1 && PORT_NAME=$2

# Wemos D1 mini
BAUD=""
BAUD="--baud 4800"
BAUD="--baud 9600"
BAUD="--baud 115200"

echo -n "To read chip ID,"
echo -n " disconnect, press the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && {
       esptool --port $PORT_NAME $BAUD chip_id || exit
}
echo -n "To backup firmware,"
echo -n " disconnect, press the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && {
        esptool --port $PORT_NAME $BAUD read_flash 0x00000 0x100000 Backup_1MB-$(date +"%Y-%M-%d-%H-%M-%S").bin || exit
}
echo -n "To erase flash,"
echo -n " disconnect, press the device's connect/reset button, connect FTDI adapter and press <y> "; read ANSW
test "$ANSW" = "y" && {
        esptool --port $PORT_NAME $BAUD erase_flash || exit
}
echo -n "To flash new firmware,"
echo    " disconnect, press the device's connect/reset button, connect FTDI adapter and press"
echo    "<e> for plain ESP32,"
echo    "<i> for inkboard based on ESP32,"
echo    "<w> for Wemos D1 mini,"
echo    "<s> for Sonoff,"
echo    "<y> for Shelly"; read ANSW
# Shelly
test "$ANSW" = "y" && esptool --port $PORT_NAME $BAUD write_flash --flash_size=4MB -fm dout 0x0 "$FLASH_FILE"
# Sonoff
test "$ANSW" = "s" && esptool --port $PORT_NAME $BAUD write_flash --flash_size=1MB -fm dout 0x0 "$FLASH_FILE"
# Wemos D1 mini
#test "$ANSW" = "w" && esptool --port $PORT_NAME $BAUD write_flash --flash_size=4MB -fm dio 0 "$FLASH_FILE"
test "$ANSW" = "w" && esptool --port $PORT_NAME $BAUD write_flash --flash_size 4MB 0x0 "$FLASH_FILE"
# ESP32
test "$ANSW" = "e" && esptool --port $PORT_NAME $BAUD write_flash 0x0 "$FLASH_FILE"
# inkboard based on ESP32
test "$ANSW" = "i" && esptool --port $PORT_NAME $BAUD --chip esp32 write_flash -z 0x1000 "$FLASH_FILE"
