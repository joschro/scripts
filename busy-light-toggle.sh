#!/bin/sh

ping -c1 -w1 192.168.178.87 >/dev/null 2>&1 && curl http://192.168.178.87/cm?cmnd=Power%20TOGGLE >/dev/null
ping -c1 -w1 10.93.124.8 >/dev/null 2>&1 && curl http://10.93.124.8/cm?cmnd=Power%20TOGGLE >/dev/null
