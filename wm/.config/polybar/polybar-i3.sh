#!/usr/bin/env sh

# Terminate already running Polyabr instances
killall -q polybar
# killall -q xfce4-power-manager
brightnessctl set 25%

# Wait until the process have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# ~/.config/polybar/colors-from-i3.sh

if [ -f "$HOME/.cache/wal/colors.sh" ]; then
  source "$HOME/.cache/wal/colors.sh"
fi

# Buscar rutas dinámicamente por NOMBRE del sensor
export HWMON_CPU=$(for i in /sys/class/hwmon/hwmon*/name; do grep -q "k10temp" "$i" && echo "${i%/*}/temp1_input"; done)
export HWMON_GPU=$(for i in /sys/class/hwmon/hwmon*/name; do grep -q "amdgpu" "$i" && echo "${i%/*}/temp1_input"; done)

# 4. Selección de Tema con Persistencia
CACHE_FILE="$HOME/.cache/polybar_theme"

if [ ! -z "$1" ]; then
  # Si pasas un argumento (ej: ./polybar-i3.sh material), usa ese
  TEMA=$1
elif [ -f "$CACHE_FILE" ]; then
  # Si NO hay argumento, lee el último tema guardado por el selector de Rofi
  TEMA=$(cat "$CACHE_FILE")
else
  # Si no hay argumento ni caché, usa un backup (puedes poner 'material' aquí)
  TEMA="material"
fi

CONFIG_PATH="$HOME/.config/polybar/bars/$TEMA/config.ini"

# 5. Lanzamiento
if [ -f "$CONFIG_PATH" ]; then
  echo "--- Lanzando Polybar con estilo: $TEMA ---"
  polybar mybar -c "$CONFIG_PATH" &
else
  echo "Error: No se encontró la configuración en $CONFIG_PATH"
  echo "Lanzando configuración base..."
  # Aquí lanzamos 'parent' o 'mybar' según como esté en tu config-i3.ini
  polybar parent -c "$HOME/.config/polybar/config-i3.ini" &
fi
