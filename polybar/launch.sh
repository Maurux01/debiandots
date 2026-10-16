#!/bin/bash
# launch.sh - (re)launch polybar without duplicates on i3 reload
pkill -x polybar 2>/dev/null || true
# wait until shutdown
for _ in $(seq 1 20); do
    pgrep -u "$UID" -x polybar >/dev/null || break
    sleep 0.2
done
polybar main 2>/tmp/polybar.log & disown
