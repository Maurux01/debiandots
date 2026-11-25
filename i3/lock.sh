#!/bin/bash
# lock.sh - pantalla de bloqueo con tema Catppuccin Mocha
# Uso: lock.sh [ruta_wallpaper]  (default: ~/.config/i3/wallpaper.jpg, luego ~/Pictures/wallpapers4rice/debian/debian_1.jpg)
# Soporta: i3lock-color (recomendado, anillo mauve) o i3lock clasico (fallback)
# Paleta: bg #1e1e2e, surface0 #313244, text #cdd6f4, mauve #cba6f7, red #f38ba8, overlay0 #6c7086

BG="1e1e2e"
BG_ALT="313244"
FG="cdd6f4"
ACCENT="cba6f7"
URGENT="f38ba8"
MUTED="6c7086"
TRANSPARENT="00000000"

if [ -n "$1" ] && [ -f "$1" ]; then
    WALLPAPER="$1"
elif [ -f "$HOME/.config/i3/wallpaper.jpg" ]; then
    WALLPAPER="$HOME/.config/i3/wallpaper.jpg"
elif [ -f "$HOME/Pictures/wallpapers4rice/debian/debian_1.jpg" ]; then
    WALLPAPER="$HOME/Pictures/wallpapers4rice/debian/debian_1.jpg"
else
    WALLPAPER=""
fi

msg_falta() {
    echo "lock: instala i3lock (sudo apt install i3lock). Para anillo Catppuccin completo usa i3lock-color." >&2
    command -v notify-send >/dev/null 2>&1 && notify-send "i3 lock" "Instala i3lock: sudo apt install i3lock"
    exit 1
}

# Pausar notificaciones mientras esta bloqueado (si dunst esta corriendo)
pausar_dunst() {
    command -v dunstctl >/dev/null 2>&1 && dunstctl set-paused true 2>/dev/null || true
}
reanudar_dunst() {
    command -v dunstctl >/dev/null 2>&1 && dunstctl set-paused false 2>/dev/null || true
}
trap reanudar_dunst EXIT

if command -v i3lock-color >/dev/null 2>&1; then
    LOCK_BIN="i3lock-color"
elif command -v i3lock >/dev/null 2>&1; then
    # i3lock clasico de Debian: sin anillo, fondo solido Catppuccin + imagen si existe
    # (sin exec: al desbloquear se reanudan las notificaciones; con exec el trap EXIT jamas corre)
    pausar_dunst
    if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
        i3lock -n -c "$BG" -i "$WALLPAPER" -t
    else
        i3lock -n -c "$BG"
    fi
    reanudar_dunst
    exit 0
else
    msg_falta
fi

# --- i3lock-color: Catppuccin Mocha ring style (mauve) ---
IMG_ARGS=()
if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    IMG_ARGS=(-i "$WALLPAPER")
fi

pausar_dunst
# (sin exec: al desbloquear se reanudan las notificaciones; con exec el trap EXIT jamas corre)
"$LOCK_BIN" -n "${IMG_ARGS[@]}" \
    --inside-color="$BG" \
    --ring-color="$ACCENT" \
    --line-uses-inside \
    --keyhl-color="$ACCENT" \
    --bshl-color="$URGENT" \
    --separator-color="$TRANSPARENT" \
    --insidever-color="$BG_ALT" \
    --insidewrong-color="$URGENT" \
    --ringver-color="$FG" \
    --ringwrong-color="$URGENT" \
    --verif-color="$FG" \
    --wrong-color="$FG" \
    --modif-color="$FG" \
    --layout-color="$MUTED" \
    --time-color="$FG" \
    --date-color="$MUTED" \
    --greeter-color="$ACCENT" \
    --verif-text="Verificando..." \
    --wrong-text="Error" \
    --noinput-text="" \
    --lock-text="" \
    --lock-failed-text="" \
    --pass-media-keys \
    --pass-screen-keys \
    --pass-volume-keys \
    --radius=120 \
    --ring-width=10 \
    --clock \
    --time-str="%H:%M" \
    --date-str="%Y-%m-%d" \
    --greeter-text="catppuccin" \
    --indicator
reanudar_dunst
exit 0
