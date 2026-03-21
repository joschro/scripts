#!/bin/sh

# https://stackpointer.io/mobile/android-adb-list-installed-package-names/416/

# adb shell pm list packages -e -3 -f

USERS=$(adb shell pm list users | grep UserInfo | cut -d'{' -f2 | cut -d':' -f1 | tr -d ' ')
for USER in $USERS; do
  echo "=== User $USER ==="
  adb shell pm list packages --user $USER -e -3 | sed 's/^package://g' | sort | tee -a installed-apps-profile-$USER.short.txt
  adb shell pm list packages --user $USER -e -3 -i | sed 's/^package://g' | sort > installed-apps-profile-$USER.short+repo.txt
  adb shell pm list packages --user $USER -e -3 -f -i | sed 's/^package://g' | sort > installed-apps-profile-$USER.long+repo.txt
  echo ""
done

