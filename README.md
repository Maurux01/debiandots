# debiandots

Minimal i3 rice for Debian with Gruvbox Dark theme.

## Includes

- i3 (gaps, vim keys), polybar, picom (blur), rofi, dunst
- Lock screen, powermenu, screenshots, static/live wallpapers
- Volume/brightness OSD, redshift night light
- JetBrainsMono Nerd Font, Papirus-Mace icons, cursorfont cursor
- GTK Gruvbox-Dark theme (Adwaita-dark como fallback)

## Install

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
| Mod+Return | terminal |
| Mod+d | rofi |
| Mod+e | file manager |
| Mod+q | close |
| Mod+h/j/k/l | focus |
| Mod+Shift+h/j/k/l | move |
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
| Mod+Shift+r / c | reload / restart |

Mod = Super key.
