#!/usr/bin/env bash

# Huion tablet monitor toggle script for Hyprland
# Toggles tablet mapping between DP-1 and HDMI-A-1

MONITOR1="DP-1"
MONITOR2="HDMI-A-1"
STATE_FILE="/tmp/tablet_monitor_state"

# Notification function - tries noctalia first, falls back to notify-send
notify() {
    local title="$1"
    local body="$2"

    if pgrep -x "noctalia-shell" >/dev/null 2>&1; then
        noctalia-shell ipc call notification notify "$title" "$body" 2>/dev/null && return
    fi

    # Fallback to notify-send
    notify-send "$title" "$body" -t 2000 2>/dev/null || true
}

# Get all Huion tablet devices from all sections (keyboards + tablets), excluding dial
mapfile -t TABLET_DEVICES < <(hyprctl devices -j | jq -r '
  (.keyboards[]? | select(.name | test("huion"; "i")) | select(.name | test("dial") | not) | .name),
  (.tablets[]? | select(.name? // "" | test("huion"; "i")) | .name)
' 2>/dev/null | sort -u)

# Also always include the known tablet device name even if not currently detected
KNOWN_TABLET="huion-huion-tablet_h640p-1"
if [[ ! " ${TABLET_DEVICES[*]} " =~ " ${KNOWN_TABLET} " ]]; then
    TABLET_DEVICES+=("$KNOWN_TABLET")
fi

# Check if any tablet devices were found
if [ ${#TABLET_DEVICES[@]} -eq 0 ]; then
    notify "Tablet Error" "Huion tablet not found"
    echo "Error: Huion tablet not found"
    exit 1
fi

echo "Found tablet devices: ${TABLET_DEVICES[*]}"

# Get current state from state file, default to MONITOR1
if [ -f "$STATE_FILE" ]; then
    CURRENT_MONITOR=$(cat "$STATE_FILE")
else
    CURRENT_MONITOR="$MONITOR1"
fi

# Toggle to the other monitor
if [ "$CURRENT_MONITOR" = "$MONITOR1" ]; then
    NEW_MONITOR="$MONITOR2"
else
    NEW_MONITOR="$MONITOR1"
fi

# Apply the change to all tablet devices
for device in "${TABLET_DEVICES[@]}"; do
    echo "Mapping $device to $NEW_MONITOR"
    hyprctl keyword "device[$device]:output" "$NEW_MONITOR" 2>/dev/null
done

# Save the new state
echo "$NEW_MONITOR" > "$STATE_FILE"

# Send notification
notify "Tablet Monitor" "Mapped to $NEW_MONITOR"

echo "Tablet mapped to $NEW_MONITOR"
