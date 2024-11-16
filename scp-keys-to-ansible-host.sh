#!/bin/sh

myHOST="$(grep "$1.*ansible" ~/Proj*/github/private/hosts | sed "s/.*_host=//g;s/\t.*//")"
myUSER="$(grep "$1.*ansible" ~/Proj*/github/private/hosts | sed "s/.*_user=//g;s/\t.*//")"

scp -i ~/.ssh-joschro/id_rsa ~/Proj*/github/private/authorized_keys $myUSER@$myHOST:/home/$myUSER/.ssh/
