#!/bin/bash
# powermenu.sh - menu apagar/reiniciar/suspender/bloquear/salir con rofi gruvbox
# Uso: powermenu.sh

OPCIONES=" Bloquear\n󰍃 Salir i3\n󰒲 Suspender\n󰜉 Reiniciar\n Apagar"
ELEGIDO=$(echo -e "$OPCIONES" | rofi -dmenu -p "Power" -theme-str 'window {width: 300px;} listview {lines: 5;}')

case "$ELEGIDO" in
    *Bloquear*) ~/.config/i3/lock.sh ;;
    *Salir*) i3-msg exit ;;
    *Suspender*) systemctl suspend ;;
    *Reiniciar*) systemctl reboot ;;
    *Apagar*) systemctl poweroff ;;
esac
