#!/bin/bash
# Dim the display at night, full brightness during the day.
# Install on Pi: sudo cp scripts/deskpet-dim.sh /usr/local/bin/ && sudo chmod +x /usr/local/bin/deskpet-dim.sh

NIGHT_START="22:30"
NIGHT_END="07:30"
DAY_BRIGHTNESS=1.0
NIGHT_BRIGHTNESS=0.35
BACKLIGHT_DAY=255
BACKLIGHT_NIGHT=80

now_h=$(date +%H)
now_m=$(date +%M)
now_minutes=$((10#$now_h * 60 + 10#$now_m))
night_start_minutes=$((22 * 60 + 30))
night_end_minutes=$((7 * 60 + 30))

if [ "$now_minutes" -ge "$night_start_minutes" ] || [ "$now_minutes" -lt "$night_end_minutes" ]; then
  xrandr_brightness=$NIGHT_BRIGHTNESS
  backlight_value=$BACKLIGHT_NIGHT
else
  xrandr_brightness=$DAY_BRIGHTNESS
  backlight_value=$BACKLIGHT_DAY
fi

# Hardware backlight (Pi official display, some Waveshare panels)
if [ -d /sys/class/backlight ]; then
  for bl in /sys/class/backlight/*; do
    max=$(cat "$bl/max_brightness" 2>/dev/null)
    if [ -n "$max" ] && [ "$max" -gt 0 ]; then
      scaled=$((backlight_value * max / 255))
      echo "$scaled" > "$bl/brightness" 2>/dev/null || \
        sudo sh -c "echo $scaled > $bl/brightness" 2>/dev/null
    fi
  done
fi

# Software brightness fallback (HDMI / most setups)
export DISPLAY=:0
if command -v xrandr >/dev/null 2>&1; then
  output=$(xrandr --current 2>/dev/null | awk '/ connected/{print $1; exit}')
  if [ -n "$output" ]; then
    xrandr --output "$output" --brightness "$xrandr_brightness" 2>/dev/null
  fi
fi
