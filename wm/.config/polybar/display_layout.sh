#!/bin/bash

LAPTOP="eDP"
EXTERNAL="HDMI-A-0"
ROFI_THEME="$HOME/.config/rofi/ScreenSelect.rasi"
ICON_DIR="$HOME/.config/rofi/assets"
CACHE_WALLPAPER="$HOME/.cache/wal/wal"

# Construimos las opciones con el formato exacto que Rofi espera
# Nota: No pongas espacios alrededor de \0
opt1="Solo Laptop\0icon\x1f${ICON_DIR}/laptop.png"
opt2="Solo Monitor\0icon\x1f${ICON_DIR}/monitor.png"
opt3="Extender\0icon\x1f${ICON_DIR}/extend.png"
opt4="Espejo\0icon\x1f${ICON_DIR}/mirror.png"

# Enviamos las opciones usando echo -e para procesar los escapes \0 y \x1f
options="${opt1}\n${opt2}\n${opt3}\n${opt4}"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Pantalla" -theme "$ROFI_THEME" -show-icons)

case $chosen in
    "Solo Laptop")
        xrandr --output $LAPTOP --auto --primary --output $EXTERNAL --off ;;
    "Solo Monitor")
        xrandr --output $EXTERNAL --auto --primary --output $LAPTOP --off ;;
    "Extender")
        xrandr --output $LAPTOP --auto --primary --output $EXTERNAL --auto --right-of $LAPTOP ;;
    "Espejo")
        xrandr --output $LAPTOP --auto --output $EXTERNAL --auto --same-as $LAPTOP ;;
    *)
        exit 0 ;;
esac

# Refresco de entorno
if [ -f "$CACHE_WALLPAPER" ]; then
    WALL="$(cat "$CACHE_WALLPAPER")"
    feh --bg-fill "$WALL"
fi

#kill old instances
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
~/.config/polybar/polybar-i3.sh &
