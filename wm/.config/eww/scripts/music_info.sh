#!/bin/bash

# Configuración
CACHE_DIR="$HOME/.cache/eww/music"
mkdir -p "$CACHE_DIR"
COVER_ART="$CACHE_DIR/cover.png"
FALLBACK_ART="$HOME/.config/eww/assets/default_art.png"

# --- NUEVA LÓGICA DE DETECCIÓN ---
# Busca el primer reproductor que esté "Playing", si no hay ninguno, usa el primero disponible.
PLAYER=$(playerctl -l 2>/dev/null | while read -r p; do
  status=$(playerctl -p "$p" status 2>/dev/null)
  if [ "$status" = "Playing" ]; then
    echo "$p"
    exit
  fi
done)

# Si no encontró ninguno reproduciendo, toma el primero de la lista
if [ -z "$PLAYER" ]; then
  PLAYER=$(playerctl -l 2>/dev/null | head -n 1)
fi
# ---------------------------------

# Función para extraer carátula de archivos locales
get_embedded_art() {
  local file_path=$(playerctl -p "$PLAYER" metadata xesam:url 2>/dev/null | sed 's|^file://||' | perl -MURI::Escape -ne 'print uri_unescape($_)')
  if [[ -f "$file_path" ]]; then
    ffmpeg -i "$file_path" "$COVER_ART" -y &>/dev/null
    echo "$COVER_ART"
  else
    echo "$FALLBACK_ART"
  fi
}

get_art() {
  local art_url=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)
  if [[ -z "$art_url" ]]; then
    get_embedded_art
  elif [[ "$art_url" =~ ^https?:// ]]; then
    curl -s "$art_url" --output "$COVER_ART"
    echo "$COVER_ART"
  elif [[ "$art_url" =~ ^file:// ]]; then
    local clean_path=$(echo "$art_url" | sed 's|^file://||' | perl -MURI::Escape -ne 'print uri_unescape($_)')
    cp "$clean_path" "$COVER_ART"
    echo "$COVER_ART"
  else
    echo "$FALLBACK_ART"
  fi
}

case "$1" in
--art) get_art ;;
--title) playerctl -p "$PLAYER" metadata title || echo "Offline" ;;
--artist) playerctl -p "$PLAYER" metadata artist || echo "Unknown" ;;
--status) playerctl -p "$PLAYER" status ;;
--perc)
  pos=$(playerctl -p "$PLAYER" position 2>/dev/null)
  len=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)
  if [[ -z "$pos" || -z "$len" || "$len" -eq 0 ]]; then
    echo 0
  else
    len_sec=$((len / 1000000))
    echo $((${pos%.*} * 100 / len_sec))
  fi
  ;;
--toggle) playerctl -p "$PLAYER" play-pause ;;
--next) playerctl -p "$PLAYER" next ;;
--prev) playerctl -p "$PLAYER" previous ;;
--set)
  target_perc=$2
  len_ms=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)
  if [ -n "$len_ms" ]; then
    target_pos=$((target_perc * len_ms / 100 / 1000000))
    playerctl -p "$PLAYER" position "$target_pos"
  fi
  ;;
esac
