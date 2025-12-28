#!/bin/sh

#atq | cut -d" " -f1 | xargs -n 1 atrm 
atq | awk '{print $1}' | xargs -r atrm

