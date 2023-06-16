#!/bin/sh

ln -s ~/Proje*/github/scripts/*sh .
ln -s ~/Proje*/github/scripts/*py .
ln -snf `ls -rt Logseq-linux-x64-* | tail -n1` Logseq-linux-x64 && chmod u+x ./Logseq-linux-x64
