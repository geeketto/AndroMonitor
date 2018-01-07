#!/bin/bash

### You can find the list of monitor with the command $ xrandr
### Uncomment what you are using
##Laptop
#fisic="LVDS1"
##Modern Laptop
fisic="eDP1"
##VGA
#fisic="VGA1"
## HDMI
#fisic="HDM1"

## ADB bin
adb_bin=/bin/adb

#echo $@

## Find android resolution
if [ -z "$device" ] ; then
	device=$($adb_bin shell dumpsys window displays | grep init | cut -d'=' -f 2 | cut -d' ' -f 1)
fi
if [ -z "$device" ] ; then
	echo "Can't read device resolution using adb"
	exit 0
else
	## Device width and height
	d_width=$(echo $device | cut -d'x' -f 1)
	d_height=$(echo $device | cut -d'x' -f 2)
	### echo $d_height
	### echo $d_width
fi

## Find host resolution
host=$(xdpyinfo  | grep 'dimensions:' | cut -d' ' -f 7)
h_width=$(echo $host | cut -d'x' -f 1)
h_height=$(echo $host | cut -d'x' -f 2)
### echo $h_height
### echo $h_width

