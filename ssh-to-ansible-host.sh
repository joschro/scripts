#!/bin/sh

myHOST="$(grep "$1.*ansible" ~/Proj*/github/private/hosts | sed "s/.*_host=//g;s/\t.*//")"
myUSER="$(grep "$1.*ansible" ~/Proj*/github/private/hosts | sed "s/.*_user=//g;s/\t.*//")"

ssh $myUSER@$myHOST || ssh -i ~/.ssh-joschro/id_rsa $myUSER@$myHOST
