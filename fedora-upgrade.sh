#!/bin/sh

test "$USER" = "root" || {
	echo "Must be root."
	exit
}

logFile="/var/log/$(basename $0)"
currentVersion=$(sed "s/.* \([[:digit:]]*\)\( .*\)/\1/g" /etc/fedora-release)
(( newVersion = $currentVersion + 1 ))

echo;echo "$(date) - Preparing for update $currentVersion -> $newVersion" | tee -a $logFile;echo

dnf clean all | tee -a $logFile
doReboot="y"
dnf check-upgrade | tee -a $logFile 
dnf check-upgrade && doReboot="n"
dnf -y upgrade --refresh | tee -a $logFile
test "$doReboot" = "y" && reboot
dnf -y install dnf-plugin-system-upgrade | tee -a $logFile
echo;echo "--------------------";echo "$(date) - Update $currentVersion -> $newVersion" | tee -a $logFile;echo
dnf -y system-upgrade download --releasever=$newVersion | tee -a $logFile
dnf system-upgrade reboot
