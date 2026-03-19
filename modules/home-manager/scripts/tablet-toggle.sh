#!/bin/bash

# Huion tablet monitor toggle script for Hyprland
# Toggles tablet mapping between DP-1 and HDMI-A-1

# Dynamically detect Huion tablet device name from hyprctl devices
TABLET_DEVICE=$(hyprctl devices | rg -A1 "Tablet at" | rg "huion" | awk '{print $1}')
MONITOR1="DP-1"
MONITOR2="HDMI-A-1"
STATE_FILE="/tmp/tablet_monitor_state"
CONFIG_FILE="/home/ubr/.config/hypr/hyprland.conf"

# Check if tablet device was found
if [ -z "$TABLET_DEVICE" ]; then
    notify-send "Tablet Error" "Huion tablet not found" -t 3000
    echo "Error: Huion tablet not found"
    exit 1
fi

# Get current tablet output from config file (device name in config has -1 suffix)
CURRENT_MONITOR=$(grep -A2 "name = $TABLET_DEVICE" "$CONFIG_FILE" | grep "output" | awk '{print $3}')

# If no current monitor found, default to MONITOR1
if [ -z "$CURRENT_MONITOR" ]; then
    CURRENT_MONITOR="$MONITOR1"
fi

# Toggle to the other monitor
if [ "$CURRENT_MONITOR" = "$MONITOR1" ]; then
    NEW_MONITOR="$MONITOR2"
else
    NEW_MONITOR="$MONITOR1"
fi

# Update the config filje (device name in config has -1 suffix)
sed -i "/name = $TABLET_DEVICE/,/output =/ s/output = .*/output = $NEW_MONITOR/" "$CONFIG_FILE"

# Apply the change immediately using hyprctl keyword
hyprctl keyword "device[$TABLET_DEVICE]:output" "$NEW_MONITOR"

# Save the new state
echo "$NEW_MONITOR" > "$STATE_FILE"

# Send notification
notify-send "Tablet Monitor" "Tablet mapped to $NEW_MONITOR" -t 2000

echo "Tablet mapped to $NEW_MONITOR"
