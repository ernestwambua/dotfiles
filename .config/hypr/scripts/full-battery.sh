#!/bin/sh

threshold=98

while true; do
  percentage=$(upower -i "$(upower -e | grep BAT)" | grep -E "percentage" | awk '{print $2}' | tr -d '%')
  state=$(upower -i "$(upower -e | grep BAT)" | grep -E "state" | awk '{print $2}')

  if [ "$percentage" -ge "$threshold" ] && [ "$state" = "charging" ]; then
    hyprctl notify 0 5000 0 "  Full battery: ${percentage}%  " &&
      pw-play ~/.config/hypr/scripts/full-battery.mp3
    sleep 240
  else
    sleep 120
  fi
done
