#!/bin/bash
# live-wp.sh - pone video como wallpaper y mata el estatico/live previo
# Uso: live-wp.sh [ruta_video]
# Default: ~/.config/i3/live-wallpaper.mp4
# Requiere: mpvpaper (Wayland / XWayland) o xwinwrap + mpv (X11)

VIDEO="${1:-$HOME/.config/i3/live-wallpaper.mp4}"

if [ ! -f "$VIDEO" ]; then
    msg="live-wp: no existe $VIDEO. Pon tu video ahi o pasa la ruta: live-wp.sh ~/video.mp4"
    echo "$msg" >&2
    command -v notify-send >/dev/null 2>&1 && notify-send "i3 live wallpaper" "$msg"
    exit 1
fi

# Matar instancia previa
pkill -f "mpvpaper" 2>/dev/null || true
pkill -f "xwinwrap" 2>/dev/null || true
sleep 0.3

if command -v mpvpaper >/dev/null 2>&1; then
    # '*' = todas las pantallas. Opciones mpv recomendadas para fondo.
    exec mpvpaper -o "loop --no-audio --panscan=1.0" '*' "$VIDEO"
elif command -v xwinwrap >/dev/null 2>&1 && command -v mpv >/dev/null 2>&1; then
    exec xwinwrap -ov -ni -g 1920x1080 -- mpv -wid WID --loop --no-audio --panscan=1.0 "$VIDEO"
else
    echo "live-wp: instala mpvpaper o (xwinwrap + mpv). Ej: sudo apt install mpv" >&2
    exit 1
fi
