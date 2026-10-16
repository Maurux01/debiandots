#!/bin/bash
# launch.sh - (re)launch polybar without duplicates on i3 reload
if ! command -v polybar >/dev/null 2>&1; then
    echo "launch: polybar no instalado" >&2
    exit 0
fi
[ -f "$HOME/.config/polybar/config.ini" ] || exit 0
pkill -x polybar 2>/dev/null || true
# wait until shutdown
for _ in $(seq 1 20); do
    pgrep -u "$UID" -x polybar >/dev/null || break
    sleep 0.2
done
polybar main 2>/tmp/polybar.log & disown
