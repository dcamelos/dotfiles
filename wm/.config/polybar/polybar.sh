#!/usr/bin/env sh

# Terminate already running Polyabr instances
pkill -f polybar_fullscreen.sh
killall -q polybar

# Wait until the process have been shut down
while pgrep -x polybar > /dev/null; do sleep 1; done

 ~/.config/polybar/colors-from-xfce.sh

# Buscar rutas dinámicamente por NOMBRE del sensor
export HWMON_CPU=$(for i in /sys/class/hwmon/hwmon*/name; do grep -q "k10temp" "$i" && echo "${i%/*}/temp1_input"; done)
export HWMON_GPU=$(for i in /sys/class/hwmon/hwmon*/name; do grep -q "amdgpu" "$i" && echo "${i%/*}/temp1_input"; done)

# Launch Polybar
polybar &
# polybar left -c ~/.config/polybar/config.ini &
# polybar center -c ~/.config/polybar/config.ini &
# polybar right -c ~/.config/polybar/config.ini &

# launch fullscreen polybar for xfwm

~/.config/polybar/polybar_fullscreen.sh &


