#!/bin/bash

# Resize target volume to occupy all available space on the partition

/usr/sbin/diskutil resizeVolume "$3" R

exit 0