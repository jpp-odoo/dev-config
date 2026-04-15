#!/bin/bash

# Path to your Omarchy bindings file
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
# The exact command that worked for you
SYNC_LINE="bindlnd = , XF86AudioMicMute, Sync Mic LED, exec, sh -c \"sleep 0.1 && wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -qi MUTED && echo 1 > /sys/class/leds/platform::micmute/brightness || echo 0 > /sys/class/leds/platform::micmute/brightness\""


echo "Step 1: Fixing hardware LED permissions..."
# 1. Apply the permanent world-writable fix via systemd-tmpfiles
sudo sh -c 'echo "f /sys/class/leds/platform::micmute/brightness 0666 root root -" > /etc/tmpfiles.d/micmute-led.conf'
sudo systemd-tmpfiles --create /etc/tmpfiles.d/micmute-led.conf

echo "Step 2: Updating Hyprland bindings..."
# 2. Add the binding to bindings.conf if it doesn't already exist
if grep -q "Sync Mic LED" "$BINDINGS_FILE"; then
    echo "Binding already exists in $BINDINGS_FILE. Skipping append."
else
    echo "" >> "$BINDINGS_FILE" # Add a newline for safety
    echo "$SYNC_LINE" >> "$BINDINGS_FILE"
    echo "Successfully added binding to $BINDINGS_FILE"
fi

echo "Step 3: Reloading Hyprland..."
hyprctl reload

echo "All done! Your ThinkPad mute light should now be synced."
