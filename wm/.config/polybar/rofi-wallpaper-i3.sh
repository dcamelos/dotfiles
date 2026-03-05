#!/bin/bash

# 1. Rutas
WALLPAPER_DIR="$HOME/Imágenes/wallpapers"
ROFI_THEME="$HOME/.config/rofi/WallSelect.rasi"
CACHE_FILE="$HOME/.cache/wal/wal"
WAL_SCRIPT="$HOME/.config/polybar/wal-tile.sh"

while true; do
  # 2. Obtener el fondo actual para resaltar la fila
  if [ -f "$CACHE_FILE" ]; then
    CURRENT_WALL_PATH=$(cat "$CACHE_FILE")
    CURRENT_WALL_NAME=$(basename "$CURRENT_WALL_PATH")
  else
    CURRENT_WALL_NAME=""
  fi

  # 3. Generar la lista
  WALLPAPER_LIST=""
  ROW_INDEX=0
  COUNTER=0

  mapfile -t ALL_WALLS < <(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) |
    sort)

  for wall in "${ALL_WALLS[@]}"; do
    filename=$(basename "$wall")
    WALLPAPER_LIST+="${filename}\0icon\x1f${wall}\n"

    if [ "$filename" == "$CURRENT_WALL_NAME" ]; then
      ROW_INDEX=$COUNTER
    fi
    ((COUNTER++))
  done

  # 4. Lanzar Rofi con el parámetro de NO CERRAR
  # -selected-row ayuda a que el scroll se mantenga donde estás
  selection=$(echo -en "$WALLPAPER_LIST" | rofi -dmenu -i \
    -p "Vista Previa de Colores" \
    -selected-row ${ROW_INDEX} \
    -theme "$ROFI_THEME")

  # 5. Si el usuario presiona ESC o cierra el menú, salimos del bucle
  if [ -z "$selection" ]; then
    break
  fi

  FULL_PATH="$WALLPAPER_DIR/$selection"

  # 6. Aplicar cambios en segundo plano
  if [ -f "$FULL_PATH" ]; then
    # Actualizamos el cache manualmente para que el bucle lo detecte YA
    echo "$FULL_PATH" >"$CACHE_FILE"

    # Ejecutamos el script de pywal
    # Mantenemos el & para que la interfaz no se trabe,
    # pero el cache ya tiene la info correcta.
    bash "$WAL_SCRIPT" "$FULL_PATH" &
  fi
  # El bucle continuará, re-lanzando Rofi instantáneamente en la misma posición
done

# #!/bin/bash

# # 1. Configura tu carpeta de fondos
# WALLPAPER_DIR="$HOME/Imágenes/wallpapers"
# ROFI_THEME="$HOME/.config/rofi/WallSelect.rasi"
# CACHE_FILE="$HOME/.cache/current_wallpaper"

# while true; do
#     # 2. Obtener el fondo actual desde el archivo de caché
#     if [ -f "$CACHE_FILE" ]; then
#         CURRENT_WALL_PATH=$(cat "$CACHE_FILE")
#         CURRENT_WALL_NAME=$(basename "$CURRENT_WALL_PATH")
#     else
#         CURRENT_WALL_NAME=""
#     fi

#     # 3. Generar la lista y encontrar el índice del actual
#     WALLPAPER_LIST=""
#     ROW_INDEX=0
#     COUNTER=0

#     while IFS= read -r wall; do
#         filename=$(basename "$wall")
#         # Formato para Rofi con iconos (asegúrate que tu Rofi soporte iconos)
#         WALLPAPER_LIST+="${filename}\0icon\x1f${wall}\n"

#         if [ "$filename" == "$CURRENT_WALL_NAME" ]; then
#             ROW_INDEX=$COUNTER
#         fi
#         ((COUNTER++))
#     done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort)

#     # 4. Lanzar Rofi
#     selection=$(echo -en "$WALLPAPER_LIST" | rofi -dmenu -i \
#         -p "Seleccionar Fondo" \
#         -selected-row ${ROW_INDEX} \
#         -theme "$ROFI_THEME")

#     # 5. Salir si se cancela
#     if [ -z "$selection" ]; then
#         break
#     fi

#     FULL_PATH="$WALLPAPER_DIR/$selection"

#     # 6. Aplicar la imagen con FEH
#     # --bg-fill ajusta la imagen llenando la pantalla (estilo crop)
#     feh --bg-fill "$FULL_PATH"

#     # Guardar para la próxima sesión de Rofi
#     echo "$FULL_PATH" > "$CACHE_FILE"

#     sleep 0.1
# done
