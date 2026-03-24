#!/usr/bin/env bash

# Directorios y Archivos
BARS_DIR="$HOME/.config/polybar/bars"
CACHE_FILE="$HOME/.cache/polybar_theme"
ICON="preferences-desktop-wallpaper" # Puedes cambiar el icono a uno de barra si prefieres

# 1. Obtener la lista de carpetas (redonda, diagonal, material)
list_bars() {
  ls -d "$BARS_DIR"/*/ 2>/dev/null | xargs -n 1 basename | sort
}

# 2. Obtener la barra actual para posicionar el cursor de Rofi
CURRENT_BAR=$(cat "$CACHE_FILE" 2>/dev/null)
[ -z "$CURRENT_BAR" ] && CURRENT_BAR="material"

# 3. Generar la lista y encontrar el índice
BAR_LIST=$(list_bars)
ROW_INDEX=$(echo "$BAR_LIST" | grep -nx "$CURRENT_BAR" | cut -d: -f1)
[ -z "$ROW_INDEX" ] && ROW_INDEX=1
ROW_INDEX=$((ROW_INDEX - 1))

# 4. Lanzar Rofi con tu tema RiceSelector.rasi
selection=$(echo "$BAR_LIST" | awk '{print $0 "\0icon\x1f'"$ICON"'"}' | rofi -dmenu -i \
  -p "Estilo de Barra:" \
  -selected-row ${ROW_INDEX} \
  -theme "$HOME/.config/rofi/RiceSelector.rasi")

# 5. Si hay selección, aplicar y guardar
if [ ! -z "$selection" ]; then
  # Guardar para persistencia
  echo "$selection" >"$CACHE_FILE"

  # Lanzar Polybar con el nuevo tema
  if [ -f "$HOME/.config/polybar/polybar-i3.sh" ]; then
    bash "$HOME/.config/polybar/polybar-i3.sh" "$selection" &
  fi

  notify-send "Polybar" "Estilo '$selection' aplicado" -i "$ICON"
fi
