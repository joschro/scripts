#!/bin/sh

ln -s ~/Proje*/github/scripts/*sh . 2>&1 | grep -v "exist"
ln -s ~/Proje*/github/scripts/*py . 2>&1 | grep -v "exist"
ln -snf `ls -rt Logseq-linux-x64-* | tail -n1` Logseq-linux-x64 && chmod u+x ./Logseq-linux-x64
