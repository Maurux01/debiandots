#!/bin/bash
# installer for i3 config by mauruxu01
# Copia los dotfiles del repo a ~/.config en Debian
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPERS_REPO="https://github.com/Maurux01/wallapapers4rice.git"
WALLPAPERS_DEST="$HOME/Pictures/wallpapers4rice"
ICONS_REPO="https://gitlab.com/macelinux/icons/papirus-mace-icon-theme.git"
GRUB_THEME_REPO="https://github.com/Shammanik/Asuka_grub_theme.git"
GRUB_THEME_NAME="Asuka"
CURSOR_NAME="cursorfont"
CURSOR_REPO="https://github.com/ccxvii/cursorfont.git"
WITH_WALLPAPERS=""
NO_WALLPAPERS=""

DEPS="i3 polybar rofi dunst picom feh i3lock xss-lock xautolock brightnessctl pavucontrol maim xclip xdotool mpv redshift git curl wget tar unzip fontconfig lxpolkit network-manager-gnome xfce4-power-manager thunar gtk2-engines-murrine gnome-themes-extra papirus-icon-theme x11-xserver-utils"
# mpvpaper/xwinwrap are NOT in Debian repos: install manually if you want live wallpapers
#   mpvpaper: https://github.com/GhostNaN/mpvpaper (Wayland)
#   xwinwrap: https://github.com/ujjwal96/xwinwrap (X11) + mpv

usage() {
    echo "Usage: ./install.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              show this help"
    echo "  -y, --yes, --with-wallpapers     install wallpapers (asks by default)"
    echo "  --without-wallpapers    skip wallpapers"
    echo "  --without-fonts         skip JetBrainsMono Nerd Font"
    echo "  --without-deps          skip apt deps"
    echo "  --without-icons         skip Papirus-Mace icons"
    echo "  --without-cursor        skip cursorfont cursor"
    echo "  --without-backup        skip backup of ~/.config"
    echo "  --with-grub             install Asuka grub theme (asks by default)"
    echo "  --without-grub          skip grub theme"
}

for arg in "$@"; do
    case "$arg" in
        -h|--help) usage; exit 0 ;;
        --with-wallpapers|-y|--yes) WITH_WALLPAPERS=1 ;;
        --without-wallpapers|--no-wallpapers) NO_WALLPAPERS=1 ;;
        --without-fonts|--no-fonts) NO_FONTS=1 ;;
        --without-deps|--no-deps) NO_DEPS=1 ;;
        --without-icons|--no-icons) NO_ICONS=1 ;;
        --without-cursor|--no-cursor) NO_CURSOR=1 ;;
        --without-backup|--no-backup) NO_BACKUP=1 ;;
        --with-grub) WITH_GRUB=1 ;;
        --without-grub|--no-grub) NO_GRUB=1 ;;
    esac
done

# Backup existing configs before overwrite
if [ -z "$NO_BACKUP" ]; then
    BACKUP_DIR="$HOME/.config-bak-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for d in i3 polybar picom rofi dunst gtk-3.0 gtk-4.0 redshift; do
        [ -d "$CONFIG_DIR/$d" ] && cp -rf "$CONFIG_DIR/$d" "$BACKUP_DIR/" 2>/dev/null || true
    done
    [ -f "$HOME/.Xresources" ] && cp -f "$HOME/.Xresources" "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "$HOME/.gtkrc-2.0" ] && cp -f "$HOME/.gtkrc-2.0" "$BACKUP_DIR/" 2>/dev/null || true
    # only mention if something was backed up
    if [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo "Backup: $BACKUP_DIR"
    else
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
else
    echo "[SKIP] Backup omitido (--without-backup)."
fi

instalar_archivo() {
    local origen="$1"
    local destino_dir="$2"
    local destino_archivo="$2/$(basename "$1")"

    if [ ! -f "$origen" ]; then
        echo "[SKIP] No existe en el repo: $origen"
        return 1
    fi

    # 1. Si no existe la carpeta, crearla
    if [ ! -d "$destino_dir" ]; then
        echo "[INFO] Creando carpeta: $destino_dir"
        mkdir -p "$destino_dir"
    fi

    # 2 y 3. Si existe vacia o llena, copiar/sobreescribir con -f
    echo "[INFO] Instalando $origen -> $destino_archivo"
    cp -f "$origen" "$destino_archivo"
}

echo "Repo: $REPO_DIR"
echo "Destino: $CONFIG_DIR"
echo ""

instalar_archivo "$REPO_DIR/i3/config" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/static-wp.sh" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/live-wp.sh" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/lock.sh" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/powermenu.sh" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/screenshot.sh" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/volume.sh" "$CONFIG_DIR/i3"
instalar_archivo "$REPO_DIR/i3/brightness.sh" "$CONFIG_DIR/i3"
chmod +x "$CONFIG_DIR/i3/static-wp.sh" "$CONFIG_DIR/i3/live-wp.sh" "$CONFIG_DIR/i3/lock.sh" "$CONFIG_DIR/i3/powermenu.sh" "$CONFIG_DIR/i3/screenshot.sh" "$CONFIG_DIR/i3/volume.sh" "$CONFIG_DIR/i3/brightness.sh" 2>/dev/null || true
instalar_archivo "$REPO_DIR/polybar/config.ini" "$CONFIG_DIR/polybar"
instalar_archivo "$REPO_DIR/polybar/launch.sh" "$CONFIG_DIR/polybar"
chmod +x "$CONFIG_DIR/polybar/launch.sh" 2>/dev/null || true
# Autodetect network interface + battery so polybar works on any machine
if [ -f "$CONFIG_DIR/polybar/config.ini" ]; then
    DET_IFACE=""
    if command -v ip >/dev/null 2>&1; then
        DET_IFACE="$(ip route get 1.1.1.1 2>/dev/null | grep -oP '(?<=dev\s)\w+' | head -n1)"
    fi
    [ -z "$DET_IFACE" ] && DET_IFACE="$(ls /sys/class/net 2>/dev/null | grep -v '^lo$' | head -n1)"
    if [ -n "$DET_IFACE" ]; then
        sed -i "s/^interface\s*=.*/interface = $DET_IFACE/" "$CONFIG_DIR/polybar/config.ini"
        echo "[INFO] Polybar net -> $DET_IFACE"
    fi
    DET_BAT=""
    for b in /sys/class/power_supply/BAT*; do
        [ -e "$b" ] && DET_BAT="$(basename "$b")" && break
    done
    if [ -n "$DET_BAT" ]; then
        sed -i "s/^battery\s*=.*/battery = $DET_BAT/" "$CONFIG_DIR/polybar/config.ini"
        echo "[INFO] Polybar battery -> $DET_BAT"
    else
        echo "[INFO] No battery found, polybar battery module may show nothing (desktop)."
    fi
fi
instalar_archivo "$REPO_DIR/picom/picom.conf" "$CONFIG_DIR/picom"
instalar_archivo "$REPO_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi"
instalar_archivo "$REPO_DIR/dunst/dunstrc" "$CONFIG_DIR/dunst"
instalar_archivo "$REPO_DIR/redshift/redshift.conf" "$CONFIG_DIR/redshift"
instalar_archivo "$REPO_DIR/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0"
instalar_archivo "$REPO_DIR/gtk-4.0/settings.ini" "$CONFIG_DIR/gtk-4.0"
if [ -f "$REPO_DIR/gtk-2.0/gtkrc" ]; then
    echo "[INFO] Instalando gtkrc -> $HOME/.gtkrc-2.0"
    cp -f "$REPO_DIR/gtk-2.0/gtkrc" "$HOME/.gtkrc-2.0"
fi
if [ -f "$REPO_DIR/x11/Xresources" ]; then
    echo "[INFO] Instalando Xresources -> $HOME/.Xresources"
    cp -f "$REPO_DIR/x11/Xresources" "$HOME/.Xresources"
    command -v xrdb >/dev/null 2>&1 && xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
fi

instalar_deps() {
    echo ""
    echo "[INFO] Deps apt: $DEPS"
    if ! command -v apt >/dev/null 2>&1; then
        echo "[WARN] No hay apt, instala manual en tu distro."
        return 0
    fi
    sudo apt update && sudo apt install -y $DEPS
    echo "[INFO] Live wallpapers need mpv (installed) + mpvpaper or xwinwrap (manual, not in Debian repos)."
}

if [ -z "$NO_DEPS" ]; then
    if [ -t 0 ] && [ -z "$WITH_WALLPAPERS" ]; then
        read -r -p "¿Instalar dependencias apt? [S/n]: " rdeps
        case "$rdeps" in
            [nN]*) echo "[SKIP] Deps omitidas." ;;
            *) instalar_deps ;;
        esac
    else
        instalar_deps
    fi
else
    echo ""
    echo "[SKIP] Deps omitidas (--without-deps)."
fi

instalar_iconos() {
    echo ""
    echo "[INFO] Iconos Papirus-Mace: $ICONS_REPO"
    if [ -d "$HOME/.local/share/icons/Papirus-Mace" ] || [ -d "$HOME/.icons/Papirus-Mace" ] || [ -d "/usr/share/icons/Papirus-Mace" ]; then
        echo "[OK] Papirus-Mace detectado, igual reinstalo para actualizar."
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "[ERROR] Necesitas git para iconos."
        return 1
    fi
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth 1 "$ICONS_REPO" "$tmp/papirus-mace"
    chmod +x "$tmp/papirus-mace/install.sh"
    # El upstream instala en $HOME por defecto o /usr/share si root
    (cd "$tmp/papirus-mace" && ./install.sh)
    rm -rf "$tmp"
    echo "[OK] Papirus-Mace instalado. Activo en gtk settings."
}

if [ -z "$NO_ICONS" ]; then
    instalar_iconos
else
    echo ""
    echo "[SKIP] Iconos omitidos (--without-icons)."
fi

echo ""
echo "[INFO] Cursor: $CURSOR_NAME ($CURSOR_REPO)"
instalar_cursor() {
    if ! command -v git >/dev/null 2>&1; then
        echo "[ERROR] Necesitas git para el cursor."
        return 1
    fi
    mkdir -p "$HOME/.icons"
    if [ -d "$HOME/.icons/$CURSOR_NAME" ]; then
        echo "[INFO] Sobreescribiendo cursor existente en ~/.icons/$CURSOR_NAME"
        rm -rf "$HOME/.icons/$CURSOR_NAME"
    fi
    echo "[INFO] Clonando cursor pixel negro X11..."
    git clone --depth 1 "$CURSOR_REPO" "$HOME/.icons/$CURSOR_NAME"
    # El repo ya trae cursors/ + cursor.theme listos, sin build
    command -v xrdb >/dev/null 2>&1 && xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
    # GTK2: preserva el archivo fuente del repo, solo ajusta el cursor
    if [ -f "$HOME/.gtkrc-2.0" ]; then
        if grep -q 'gtk-cursor-theme-name' "$HOME/.gtkrc-2.0"; then
            sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=\"$CURSOR_NAME\"/" "$HOME/.gtkrc-2.0"
        else
            printf 'gtk-cursor-theme-name="%s"\n' "$CURSOR_NAME" >> "$HOME/.gtkrc-2.0"
        fi
    else
        printf 'gtk-cursor-theme-name="%s"\n' "$CURSOR_NAME" > "$HOME/.gtkrc-2.0"
    fi
    command -v gsettings >/dev/null 2>&1 && gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_NAME" 2>/dev/null || true
    echo "[OK] Cursor $CURSOR_NAME instalado en ~/.icons/$CURSOR_NAME"
}
if [ -z "$NO_CURSOR" ]; then
    instalar_cursor
else
    echo "[SKIP] Cursor omitido (--without-cursor)."
fi

echo ""
echo "[INFO] GRUB theme: $GRUB_THEME_NAME ($GRUB_THEME_REPO)"
echo "  NOTA: modifica el bootloader, requiere sudo. Solo 1920x1080 segun upstream."
instalar_grub() {
    if [ -d "$REPO_DIR/grub" ] && [ -n "$(ls -A "$REPO_DIR/grub" 2>/dev/null)" ]; then
        echo "[INFO] Theme local en grub/, instalando a /boot/grub/themes/ (requiere sudo)..."
        sudo mkdir -p /boot/grub/themes
        sudo cp -rf "$REPO_DIR/grub/." /boot/grub/themes/
        FIRST_THEME="$(find /boot/grub/themes -maxdepth 2 -name theme.txt 2>/dev/null | head -n1)"
        if [ -n "$FIRST_THEME" ]; then
            echo "[INFO] Activa con: GRUB_THEME=\"$FIRST_THEME\" en /etc/default/grub + sudo update-grub"
        fi
        return 0
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "[ERROR] Necesitas git para el grub theme."
        return 1
    fi
    local tmp
    tmp="$(mktemp -d)"
    echo "[INFO] Clonando $GRUB_THEME_NAME..."
    git clone --depth 1 "$GRUB_THEME_REPO" "$tmp/asuka-grub"
    if [ -x "$tmp/asuka-grub/install.sh" ]; then
        echo "[INFO] Ejecutando instalador upstream con sudo (copia theme + update-grub)..."
        (cd "$tmp/asuka-grub" && sudo ./install.sh)
    else
        echo "[INFO] Sin install.sh upstream, copia manual a /usr/share/grub/themes/..."
        sudo mkdir -p /usr/share/grub/themes
        sudo cp -rf "$tmp/asuka-grub/asuka" /usr/share/grub/themes/
        echo "[INFO] Activa con: GRUB_THEME=\"/usr/share/grub/themes/asuka/theme.txt\" + sudo update-grub"
    fi
    rm -rf "$tmp"
    echo "[OK] GRUB $GRUB_THEME_NAME instalado."
}
if [ -n "$NO_GRUB" ]; then
    echo "[SKIP] GRUB omitido (--without-grub)."
elif [ -n "$WITH_GRUB" ]; then
    instalar_grub
elif [ -t 0 ]; then
    read -r -p "¿Instalar grub theme $GRUB_THEME_NAME? Modifica el bootloader [s/N]: " rgrub
    case "$rgrub" in
        [sSyY]*) instalar_grub ;;
        *) echo "[SKIP] GRUB omitido." ;;
    esac
else
    echo "[SKIP] GRUB omitido (modo no interactivo, usa --with-grub)."
fi

instalar_jetbrains_nerd() {
    echo ""
    echo "[INFO] Fuente: JetBrainsMono Nerd Font"

    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        echo "[OK] JetBrainsMono Nerd Font ya instalada, skip."
        return 0
    fi

    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    mkdir -p "$font_dir"
    local tmp_file="/tmp/JetBrainsMono.tar.xz"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

    echo "[INFO] Descargando $url ..."
    if command -v curl >/dev/null 2>&1; then
        curl -fL -o "$tmp_file" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$tmp_file" "$url"
    else
        echo "[ERROR] Necesitas curl o wget: sudo apt install curl"
        return 1
    fi

    echo "[INFO] Instalando en $font_dir ..."
    tar -xJkf "$tmp_file" -C "$font_dir"
    rm -f "$tmp_file"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir" >/dev/null
    else
        echo "[WARN] Instala fontconfig para refrescar cache: sudo apt install fontconfig"
    fi

    echo "[OK] JetBrainsMono Nerd Font instalada."
}

if [ -z "$NO_FONTS" ]; then
    instalar_jetbrains_nerd
else
    echo ""
    echo "[SKIP] Fuentes omitidas (--without-fonts)."
fi

instalar_wallpapers() {
    echo ""
    echo "Wallpapers: $WALLPAPERS_REPO"
    echo "Destino: $WALLPAPERS_DEST"

    if ! command -v git >/dev/null 2>&1; then
        echo "[ERROR] Necesitas git para descargar wallpapers: sudo apt install git"
        return 1
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' RETURN

    echo "[INFO] Clonando wallpapers (shallow)..."
    git clone --depth 1 "$WALLPAPERS_REPO" "$tmp_dir/wallapapers4rice"

    mkdir -p "$WALLPAPERS_DEST"
    # Sobreescribe si ya existia (coleccion completa)
    cp -rf "$tmp_dir/wallapapers4rice/wallpapers/." "$WALLPAPERS_DEST/"

    # Deja un default funcional para i3 (no rompe el autostart)
    if [ -f "$WALLPAPERS_DEST/debian/debian_1.jpg" ]; then
        cp -f "$WALLPAPERS_DEST/debian/debian_1.jpg" "$CONFIG_DIR/i3/wallpaper.jpg"
        echo "[INFO] wallpaper.jpg por defecto -> $CONFIG_DIR/i3/wallpaper.jpg"
    fi

    # Si hay live wallpapers, deja el primero como default
    local first_live
    first_live="$(find "$WALLPAPERS_DEST/live" -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' \) 2>/dev/null | head -n 1)"
    if [ -n "$first_live" ]; then
        cp -f "$first_live" "$CONFIG_DIR/i3/live-wallpaper.mp4"
        echo "[INFO] live-wallpaper.mp4 por defecto -> $CONFIG_DIR/i3/live-wallpaper.mp4"
    fi

    rm -rf "$tmp_dir"
    trap - RETURN
    echo "[OK] Wallpapers instalados en $WALLPAPERS_DEST"
}

# --- Pregunta wallpapers: flag > prompt interactivo > skip por defecto ---
if [ -n "$NO_WALLPAPERS" ]; then
    echo ""
    echo "[SKIP] Wallpapers omitidos (--without-wallpapers)."
elif [ -n "$WITH_WALLPAPERS" ]; then
    instalar_wallpapers
elif [ -t 0 ]; then
    echo ""
    read -r -p "¿Quieres instalar los wallpapers de $WALLPAPERS_REPO? [s/N]: " respuesta
    case "$respuesta" in
        [sSyY]*) instalar_wallpapers ;;
        *) echo "[SKIP] Wallpapers omitidos." ;;
    esac
else
    echo ""
    echo "[SKIP] Wallpapers omitidos (modo no interactivo, usa --with-wallpapers para incluirlos)."
fi

echo ""
echo "--- Validacion ---"
FALTA=0
for bin in i3 polybar rofi dunst picom feh i3lock xss-lock xautolock brightnessctl pactl maim xclip xrdb redshift git curl; do
    if command -v "$bin" >/dev/null 2>&1; then
        echo "[OK] $bin"
    else
        echo "[FALTA] $bin (sudo apt install $bin)"
        FALTA=1
    fi
done
for s in static-wp.sh live-wp.sh lock.sh powermenu.sh screenshot.sh volume.sh brightness.sh; do
    if [ -f "$REPO_DIR/i3/$s" ]; then
        if bash -n "$REPO_DIR/i3/$s"; then
            echo "[OK] i3/$s syntax"
        else
            echo "[ERROR] i3/$s syntax"
            FALTA=1
        fi
    fi
done
if [ -f "$REPO_DIR/polybar/launch.sh" ]; then
    if bash -n "$REPO_DIR/polybar/launch.sh"; then
        echo "[OK] polybar/launch.sh syntax"
    else
        echo "[ERROR] polybar/launch.sh syntax"
        FALTA=1
    fi
fi
for f in "$CONFIG_DIR/i3/config" "$CONFIG_DIR/polybar/config.ini" "$CONFIG_DIR/picom/picom.conf" "$CONFIG_DIR/rofi/config.rasi" "$CONFIG_DIR/dunst/dunstrc" "$CONFIG_DIR/redshift/redshift.conf"; do
    if [ -f "$f" ]; then
        echo "[OK] instalado: $f"
    else
        echo "[FALTA] no instalado: $f"
        FALTA=1
    fi
done
if command -v i3 >/dev/null 2>&1 && [ -f "$CONFIG_DIR/i3/config" ]; then
    if i3 -C -c "$CONFIG_DIR/i3/config" 2>/dev/null; then
        echo "[OK] i3 config valida"
    else
        echo "[WARN] i3 -C fallo, revisa $CONFIG_DIR/i3/config"
    fi
else
    echo "[SKIP] i3 -C (i3 no instalado o sin config aun)"
fi
if [ "$FALTA" = "1" ]; then
    echo "[WARN] Faltan binarios, corre con deps: ./install.sh (acepta apt) o sudo apt install ..."
fi

echo ""
echo "Listo. Configs instaladas/sobreescritas correctamente."
