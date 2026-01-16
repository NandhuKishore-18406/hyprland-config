#!/bin/bash

# Auto-detect battery
BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT|^CMB' | head -n 1)

# If no battery found
if [ -z "$BAT" ]; then
    printf '{"text":"PWR ?"}\n'
    exit 0
fi

CAP_FILE="/sys/class/power_supply/$BAT/capacity"
STAT_FILE="/sys/class/power_supply/$BAT/status"

# Read values safely
CAP=$(cat "$CAP_FILE" 2>/dev/null)
STAT=$(cat "$STAT_FILE" 2>/dev/null)

# Validate capacity
if ! [[ "$CAP" =~ ^[0-9]+$ ]]; then
    printf '{"text":"PWR ?"}\n'
    exit 0
fi

BARS=$((CAP / 10))
EMPTY=$((10 - BARS))

BAR="$(printf '%*s' "$BARS" | tr ' ' '#')$(printf '%*s' "$EMPTY" | tr ' ' '-')"

[ "$STAT" = "Charging" ] && STATE="+" || STATE="-"

printf '{"text":"PWR%s [%s] %d%%"}\n' "$STATE" "$BAR" "$CAP"
