#!/bin/bash

# 1. Configura tu carpeta de fondos
WALLPAPER_DIR="$HOME/Imágenes/wallpapers"
ROFI_THEME="$HOME/.config/rofi/WallSelect.rasi"

while true; do
    # 2. Obtener el fondo actual para saber qué resaltar
    # Buscamos la primera propiedad que tenga una imagen para usarla de referencia
    FIRST_PROP=$(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image" | head -n 1)
    CURRENT_WALL_PATH=$(xfconf-query -c xfce4-desktop -p "$FIRST_PROP")
    CURRENT_WALL_NAME=$(basename "$CURRENT_WALL_PATH")

    # 3. Generar la lista y encontrar el índice del actual
    WALLPAPER_LIST=""
    ROW_INDEX=-1
    COUNTER=0

    # Usamos un array o proceso para listar y ordenar
    while IFS= read -r wall; do
        filename=$(basename "$wall")
        WALLPAPER_LIST+="${filename}\0icon\x1f${wall}\n"
        
        if [ "$filename" == "$CURRENT_WALL_NAME" ]; then
            ROW_INDEX=$COUNTER
        fi
        ((COUNTER++))
    done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort)

    # 4. Lanzar Rofi
    selection=$(echo -en "$WALLPAPER_LIST" | rofi -dmenu -i \
        -p "Seleccionar Fondo" \
        -selected-row ${ROW_INDEX:-0} \
        -a ${ROW_INDEX:-0} \
        -theme "$ROFI_THEME")

    # 5. Si se pulsa ESC o se cierra Rofi (selección vacía), salir del bucle
    if [ -z "$selection" ]; then
        break
    fi

    FULL_PATH="$WALLPAPER_DIR/$selection"

    # 6. Aplicar la imagen a todos los monitores y workspaces
    properties=$(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image")

    for prop in $properties; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$FULL_PATH"
    done
    
    # Pequeña pausa opcional para evitar doble pulsación accidental
    sleep 0.1
done
