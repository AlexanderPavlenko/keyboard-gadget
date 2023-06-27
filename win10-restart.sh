#!/bin/bash

set -xe

# CTRL+ALT+DEL
echo -ne "\x05\0\x4c\0\0\0\0\0" > /dev/hidg0
sleep 1
echo -ne "\0\0\0\0\0\0\0\0" > /dev/hidg0

# UpArrow
echo -ne "\0\0\x52\0\0\0\0\0" > /dev/hidg0
echo -ne "\0\0\0\0\0\0\0\0" > /dev/hidg0

# ENTER
echo -ne "\0\0\x28\0\0\0\0\0" > /dev/hidg0
echo -ne "\0\0\0\0\0\0\0\0" > /dev/hidg0

sleep 1

# UpArrow
echo -ne "\0\0\x52\0\0\0\0\0" > /dev/hidg0
echo -ne "\0\0\0\0\0\0\0\0" > /dev/hidg0

# ENTER
echo -ne "\0\0\x28\0\0\0\0\0" > /dev/hidg0
echo -ne "\0\0\0\0\0\0\0\0" > /dev/hidg0

echo "expecting transition from logged in to restarting"
