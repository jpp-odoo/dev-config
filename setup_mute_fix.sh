#!/bin/bash
# Fix ThinkPad mic mute LED sync for Hyprland/PipeWire (ThinkPad L14 Gen 6)
#
# Problem: Two issues with the mic mute button:
# 1. swayosd-client --input-volume mute-toggle silently fails on this hardware
# 2. The kernel's snd_ctl_led module auto-controls the LED via ALSA trigger
#    "audio-micmute", but PipeWire mute (wpctl) doesn't update ALSA state
#
# Fix: Disable kernel auto-control of mic mute LED (trigger=none) so the
# Hyprland binding can manage it. The binding uses wpctl for the actual mute
# toggle and syncs the LED afterwards.
#
# Note: Speaker mute LED (platform::mute) works correctly with its kernel
# trigger "audio-mute" — this script does NOT touch it.

set -e

echo "Setting up ThinkPad mic mute LED fix..."

# Create a systemd service to disable the mic mute LED kernel trigger
# and set permissions at boot (after sound subsystem is ready).
sudo tee /etc/systemd/system/thinkpad-mute-leds.service > /dev/null << 'EOF'
[Unit]
Description=Disable kernel auto-control of ThinkPad mic mute LED
After=sound.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c '\
  echo none > /sys/class/leds/platform::micmute/trigger; \
  chmod 666 /sys/class/leds/platform::micmute/brightness'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable thinkpad-mute-leds.service

# Apply immediately
echo none | sudo tee /sys/class/leds/platform::micmute/trigger > /dev/null
sudo chmod 666 /sys/class/leds/platform::micmute/brightness

# Restore speaker mute LED to kernel auto-control (in case it was changed)
echo audio-mute | sudo tee /sys/class/leds/platform::mute/trigger > /dev/null

# Clean up old tmpfiles.d config if it exists
sudo rm -f /etc/tmpfiles.d/micmute-led.conf

# Sync mic LED to current PipeWire state
wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -qi MUTED \
  && echo 1 > /sys/class/leds/platform::micmute/brightness \
  || echo 0 > /sys/class/leds/platform::micmute/brightness

echo "Done! Now reload Hyprland: hyprctl reload"
