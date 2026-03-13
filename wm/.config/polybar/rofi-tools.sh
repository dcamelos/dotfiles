#!/bin/bash

# Definir opciones
options="🖼️ Wallpaper\n🎨 Themes\n📝 Cheatsheet"

# Lanzar Rofi y capturar la elección
# El parámetro -selected-row -1 evita que la primera línea esté marcada al abrir
chosen=$(echo -e "$options" | rofi -dmenu -i -selected-row -1 -p " Herramientas i3" -theme ~/.config/rofi/launcher_compact.rasi)

# Lógica de ejecución
case "$chosen" in
"🖼️ Wallpaper")
  /home/$USER/.config/polybar/rofi-wallpaper-i3.sh
  ;;
"🎨 Themes")
  /home/$USER/.config/polybar/rofi-themes-i3.sh
  ;;
"📝 Cheatsheet")
  eww open csheet
  ;;
esac
