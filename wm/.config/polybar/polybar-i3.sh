#!/usr/bin/env sh

# Terminate already running Polyabr instances
killall -q polybar
# killall -q xfce4-power-manager
brightnessctl set 25%

# Wait until the process have been shut down
while pgrep -x polybar > /dev/null; do sleep 1; done

 # ~/.config/polybar/colors-from-i3.sh

 if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
fi

# Buscar rutas dinámicamente por NOMBRE del sensor
export HWMON_CPU=$(for i in /sys/class/hwmon/hwmon*/name; do grep -q "k10temp" "$i" && echo "${i%/*}/temp1_input"; done)
export HWMON_GPU=$(for i in /sys/class/hwmon/hwmon*/name; do grep -q "amdgpu" "$i" && echo "${i%/*}/temp1_input"; done)

# Launch Polybar
polybar mybar -c  ~/.config/polybar/config-i3.ini &
# polybar left -c ~/.config/polybar/config.ini &
# polybar center -c ~/.config/polybar/config.ini &
# polybar right -c ~/.config/polybar/config.ini &




