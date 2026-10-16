#!/bin/bash
# static-wp.sh - pone wallpaper estatico y mata cualquier live wallpaper previo
# Uso: static-wp.sh [ruta_imagen]
# Default: ~/.config/i3/wallpaper.jpg

WALLPAPER="${1:-$HOME/.config/i3/wallpaper.jpg}"

# Matar live wallpaper previo si existe
pkill -f "mpvpaper" 2>/dev/null || true
pkill -f "xwinwrap" 2>/dev/null || true

if [ ! -f "$WALLPAPER" ]; then
    msg="static-wp: no existe $WALLPAPER. Pon tu imagen ahi o pasa la ruta: static-wp.sh ~/imagen.jpg"
    echo "$msg" >&2
    command -v notify-send >/dev/null 2>&1 && notify-send "i3 wallpaper" "$msg"
    # Fallback: fondo solido gruvbox para no dejar la pantalla negra/rota en autostart
    command -v xsetroot >/dev/null 2>&1 && xsetroot -solid "#282828" || true
    exit 0
fi

if command -v feh >/dev/null 2>&1; then
    exec feh --bg-fill "$WALLPAPER"
elif command -v xwallpaper >/dev/null 2>&1; then
    exec xwallpaper --zoom "$WALLPAPER"
elif command -v nitrogen >/dev/null 2>&1; then
    exec nitrogen --set-zoom-fill --save "$WALLPAPER"
elif command -v xsetroot >/dev/null 2>&1; then
    exec xsetroot -solid "#282828"
else
    echo "static-wp: instala feh (sudo apt install feh) o xwallpaper/nitrogen" >&2
    exit 1
fi
