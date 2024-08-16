#!/bin/sh

# Speed in words per minute, default is 160.
speed="-s 160"

# Amplitude, 0 to 20, default is 10.
amplitude="-a 20"

#Word gap. Pause between words, units of 10 ms at the default speed.
gap="-g 5"

#Indicate capital letters with: 1=sound, 2=the word "capitals", higher values = a pitch increase (try -k20).
capitals="-k 20"

#Line length. If not zero (which is the default), consider lines less than this length as and-of-clause.
length="-l 0"

#Pitch adjustment, 0 to 99, default is 50.
pitch="-p 60"

#Use voice file of this name from espeak-data/voices.
voice="-v mb-de5-en"

options="$speed $amplitude $gap $capitals $length $pitch $voice"

# festval:
options="--tts"
case "$1" in
	-houronly)
	       #date '+Its %-H a clock'|espeak $options >/dev/null 2>/dev/null;
	       date '+Its %-H a clock'| festival $options >/dev/null 2>/dev/null;
	       ;;
	-hourminute)
		#date '+Its %-H a clock'| espeak $options >/dev/null 2>/dev/null;
		date '+Its %-H a clock'| festival $options >/dev/null 2>/dev/null;
		;;
	*)
		#echo 'Please specify a parameter'|espeak $options >/dev/null 2>/dev/null;
		echo 'Please specify a parameter'| festival $options >/dev/null 2>/dev/null;
esac
