#!/bin/sh

# Removes all user-based and system font caches

sudo atsutil databases -remove

# Stops the Apple Type Services service

sudo atsutil server -shutdown

# Starts the Apple Type Services service

sudo atsutil server -ping
