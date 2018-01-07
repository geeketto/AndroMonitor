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
## Parsen of manual resolution
device=$(echo $@ | grep -Po '\d+x\d+')

## Position of android divice left or right
position=$(echo $@ | grep -Po '\--(left|right)' | grep -Po '\w+')

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

## Build the modeline for the monitore config
modeline=$(gtf $d_width $d_height 60 | grep "Modeline" | cut -d' ' -f 4-17)
### echo $modeline
mode=$(gtf $d_width $d_height 60 | grep "Modeline" | cut -d' ' -f 4-5)
res=$(echo ${mode// \" })

## Set the default position use for a new monitor
if [ -z "$position" ] ; then
	position="right"
fi
if [ "$position" = "left" ] ; then
	xinerama="xinerama0"
else
	xinerama="xinerama1"
fi
## Run the command and log ### vaffanculo inglese di merda
function run () {
	echo "$1"
	$1
}

## Create a virtua monitor
run "xrandr --newmode $modeline"
run "xrandr --addmode VIRTUAL1 $res"
run "xrandr --output VIRTUAL1 --mode $mode --{$position}-of ${fisic}"

## GOOD MAN!

## Run the VNC server
run "x11vnc -clip ${position} -xrandr" ##-ncache 1 -nosel -fixscreen \"V=2\" -noprimary -nosetclipboard -noclipboard -cursor arrow -nopw -nowf -nonap -noxdamage -sb 0 -display :0"

## Turn AndroMonitor off
run "xrandr --output $virtual --off"
run "xrandr --delmode $virtual $mode"
run "xrandr --rmmode $mode"
run "xrandr -s 0"
