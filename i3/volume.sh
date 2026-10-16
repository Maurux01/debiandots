#!/bin/bash
# volume.sh - cambia volumen con pactl y muestra OSD via dunst
# Uso: volume.sh [up|down|mute]

notify() {
    local msg="$1" val="$2"
    if command -v dunstify >/dev/null 2>&1; then
        dunstify -a "volume" -u low -h "int:value:$val" "Volume" "$msg"
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send -a "volume" -u low "Volume" "$msg"
    fi
}

if ! command -v pactl >/dev/null 2>&1; then
    notify "pactl no instalado (sudo apt install pulseaudio-utils)" 0
    echo "volume: instala pactl (sudo apt install pulseaudio-utils)" >&2
    exit 1
fi

case "$1" in
    up) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
    down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
    mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    *) echo "Uso: volume.sh [up|down|mute]" >&2; exit 1 ;;
esac

VOL="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o '[0-9][0-9]*%' | head -n1 | tr -d '%')"
MUTED="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qi yes && echo 1 || echo 0)"
[ -z "$VOL" ] && VOL=0

if [ "$MUTED" = "1" ]; then
    notify "Muted" 0
else
    notify "${VOL}%" "$VOL"
fi
