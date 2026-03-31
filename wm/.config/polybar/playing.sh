#!/bin/bash

# Colores de tu colors.scss (ajustados a formato Polybar %{F#hex})
# Usando $cyan para el icono y $fg para el texto
ICON_COLOR="#7dcfff"
TEXT_COLOR="#fffbef"

# Obtener el estado del reproductor
PLAYER_STATUS=$(playerctl status 2>/dev/null)

if [ "$PLAYER_STATUS" = "Playing" ]; then
  echo "%{F$ICON_COLOR}󰎆 %{F$TEXT_COLOR}$(playerctl metadata --format "{{ title }} - {{ artist }}")"
elif [ "$PLAYER_STATUS" = "Paused" ]; then
  echo "%{F$ICON_COLOR}󰏤 %{F$TEXT_COLOR}Pausado"
else
  echo "" # No mostrar nada si no hay nada activo
fi
