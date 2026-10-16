#!/bin/bash
# screenshot.sh - captura full / seleccion / ventana con maim + xclip
# Uso: screenshot.sh [full|select|window]
# Guarda en ~/Pictures/screenshots/ y copia al clipboard

MODO="${1:-select}"
DIR="$HOME/Pictures/screenshots"
mkdir -p "$DIR"
FILE="$DIR/shot-$(date +%Y%m%d-%H%M%S).png"

if ! command -v maim >/dev/null 2>&1; then
    echo "screenshot: instala maim (sudo apt install maim xclip)" >&2
    command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot" "Instala maim: sudo apt install maim xclip"
    exit 1
fi

case "$MODO" in
    full) maim "$FILE" ;;
    window)
        # Si xdotool falla/no existe, caer a seleccion en vez de error
        if command -v xdotool >/dev/null 2>&1 && wid="$(xdotool getactivewindow 2>/dev/null)" && [ -n "$wid" ]; then
            maim -i "$wid" "$FILE"
        else
            maim -s "$FILE"
        fi ;;
    *) maim -s "$FILE" ;; # select por defecto
esac

command -v xclip >/dev/null 2>&1 && xclip -selection clipboard -t image/png -i "$FILE"
command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot" "Guardado en $FILE"
echo "$FILE"
