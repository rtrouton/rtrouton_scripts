#!/bin/sh

# This script will clear out the common cache folders
# as well as clearing the virtual memory swapfile

sudo rm -rf /Library/Caches/*
sudo rm -rf /System/Library/Caches/*
sudo rm -rf /Users/*/Library/Caches/*
sudo rm -rf /var/vm/swapfile0