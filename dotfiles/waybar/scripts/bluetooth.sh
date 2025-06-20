#!/bin/bash

# Get list of connected devices
devices=$(bluetoothctl info | grep "Name" | cut -d ' ' -f2-)

if [ -n "$devices" ]; then
    echo "{\"text\": \"\", \"tooltip\": \"Bluetooth: $devices\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"Bluetooth off or no devices connected\", \"class\": \"disconnected\"}"
fi
