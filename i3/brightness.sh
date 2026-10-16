#!/bin/bash
# brightness.sh - cambia brillo con brightnessctl y muestra OSD via dunst
# Uso: brightness.sh [up|down]

notify() {
    local msg="$1" val="$2"
    if command -v dunstify >/dev/null 2>&1; then
        dunstify -a "brightness" -u low -h "int:value:$val" "Brightness" "$msg"
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send -a "brightness" -u low "Brightness" "$msg"
    fi
}

if ! command -v brightnessctl >/dev/null 2>&1; then
    notify "brightnessctl no instalado" 0
    exit 1
fi

case "$1" in
    up) brightnessctl set +5% >/dev/null ;;
    down) brightnessctl set 5%- >/dev/null ;;
    *) echo "Uso: brightness.sh [up|down]" >&2; exit 1 ;;
esac

VAL="$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')"
[ -z "$VAL" ] && VAL=0
notify "${VAL}%" "$VAL"
