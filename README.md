# debiandots

Minimal i3 rice for Debian with **Catppuccin Mocha** (el mas oscuro), GTK mauve e iconos Catppuccin.

## Includes

- i3 (gaps, vim keys), polybar, picom (blur), rofi, dunst
- Lock screen, powermenu, screenshots, static/live wallpapers
- Volume/brightness OSD, redshift night light
- JetBrainsMono Nerd Font (consola) + Nerd Fonts Symbols (glyfos), kitty config
- Iconos de app y carpetas `Catppuccin-SE`, cursorfont cursor
- GTK `Catppuccin-Mauve-Dark` (tema actual como fallback)

## Install

One-liner (descarga el repo a un temporal y ejecuta el instalador, sin clonar):

```bash
curl -fsSL https://raw.githubusercontent.com/Maurux01/debiandots/main/install.sh | bash
```

Para pasar flags usa `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/Maurux01/debiandots/main/install.sh | bash -s -- --with-wallpapers --without-grub
curl -fsSL https://raw.githubusercontent.com/Maurux01/debiandots/main/install.sh | bash -s -- --help
```

Más seguro (revisa el script antes de ejecutarlo; también funciona suelto fuera del repo):

```bash
curl -fsSLo install.sh https://raw.githubusercontent.com/Maurux01/debiandots/main/install.sh
less install.sh
bash install.sh
```

Clásico (clonando):

```bash
git clone https://github.com/Maurux01/debiandots.git
cd debiandots
chmod +x install.sh
./install.sh
```

Flags: `--with-wallpapers`, `--without-wallpapers`, `--without-fonts`, `--without-deps`, `--without-icons`, `--without-cursor`, `--without-gtk-theme`, `--without-backup`, `--with-grub`, `--without-grub`, `--help`.

Backs up existing configs to `~/.config-bak-<date>`. Live wallpapers need `mpv` (auto) + `mpvpaper`/`xwinwrap` (manual).

Wallpapers: https://github.com/Maurux01/wallapapers4rice

## Keybinds

| Keys | Action |
| ---- | ------ |
| Mod+Return | terminal (kitty + JetBrainsMono Nerd Font) |
| Mod+d | rofi |
| Mod+e | file manager |
| Mod+q | close |
| Mod+h/j/k/l | focus |
| Mod+Shift+h/j/k/l | move |
| Mod+1..0 | switch workspace |
| Mod+Shift+1..0 | move to workspace |
| Mod+w / Mod+s | tabbed / stacking |
| Mod+f / Mod+v | fullscreen / split vertical |
| Mod+Shift+space / Mod+Shift+e | floating toggle / split toggle |
| Mod+Shift+v | volume GUI (pavucontrol) |
| XF86AudioRaise/Lower/Mute | volume up / down / mute (OSD) |
| XF86MonBrightnessUp/Down | brightness up / down (OSD) |
| XF86ScreenSaver | lock |
| Mod+Ctrl+l | lock |
| Mod+Shift+x | powermenu |
| Print / Mod+Print / Mod+Shift+s | screenshot select / full / select |
| Mod+Shift+w | static wallpaper |
| Mod+Ctrl+Shift+w | live wallpaper |
| Mod+Shift+n | redshift toggle |
| Mod+Shift+c / r | reload / restart |

Mod = Super key.
