#!/bin/bash
# powermenu.sh - menu apagar/reiniciar/suspender/bloquear/salir con rofi Catppuccin
# Uso: powermenu.sh

if ! command -v rofi >/dev/null 2>&1; then
    echo "powermenu: instala rofi (sudo apt install rofi)" >&2
    command -v notify-send >/dev/null 2>&1 && notify-send "Powermenu" "Instala rofi: sudo apt install rofi"
    exit 1
fi

OPCIONES=" Bloquear\n󰍃 Salir i3\n󰒲 Suspender\n󰜉 Reiniciar\n Apagar"
ELEGIDO=$(echo -e "$OPCIONES" | rofi -dmenu -p "Power" -theme-str 'window {width: 300px;} listview {lines: 5;}')
[ -z "$ELEGIDO" ] && exit 0

case "$ELEGIDO" in
    *Bloquear*) ~/.config/i3/lock.sh ;;
    *Salir*) i3-msg exit ;;
    *Suspender*) systemctl suspend ;;
    *Reiniciar*) systemctl reboot ;;
    *Apagar*) systemctl poweroff ;;
esac
