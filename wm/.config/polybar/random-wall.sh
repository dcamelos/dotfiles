#!/bin/bash

# Rutas (Mismas que tu script original)
WALLPAPER_DIR="$HOME/Imágenes/wallpapers"
CACHE_FILE="$HOME/.cache/wal/wal"
WAL_SCRIPT="$HOME/.config/polybar/wal-tile.sh"

# 1. Seleccionar un wallpaper al azar
# Buscamos archivos, sorteamos al azar y tomamos el primero
SELECTED_WALL=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

# 2. Aplicar si se encontró un archivo
if [ -f "$SELECTED_WALL" ]; then
  # Actualizar cache
  echo "$SELECTED_WALL" >"$CACHE_FILE"

  # Ejecutar tu script de pywal/polybar
  bash "$WAL_SCRIPT" "$SELECTED_WALL"
fi
