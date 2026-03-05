#!/bin/bash

# Directorios de temas
THEMES_DIR_SYS="/usr/share/themes"
THEMES_DIR_USER="$HOME/.themes"
ICON="preferences-desktop-theme"

# Función para listar temas sin adornos extras primero
list_themes() {
    for theme in $(ls "$THEMES_DIR_SYS" "$THEMES_DIR_USER" 2>/dev/null); do
        if [ -d "$THEMES_DIR_SYS/$theme/gtk-3.0" ] || [ -d "$THEMES_DIR_USER/$theme/gtk-3.0" ]; then
            echo "$theme"
        fi
    done | sort -u
}

while true; do
    # 1. Obtener el tema que está aplicado actualmente en el sistema
    CURRENT_THEME=$(xfconf-query -c xsettings -p /Net/ThemeName)
    
    # 2. Generar la lista completa
    THEME_LIST=$(list_themes)
    
    # 3. Encontrar el número de línea del tema actual (empezando desde 0)
    ROW_INDEX=$(echo "$THEME_LIST" | grep -nx "$CURRENT_THEME" | cut -d: -f1)
    ROW_INDEX=$((ROW_INDEX - 1))

    # 4. Lanzar Rofi
    # Pasamos la lista con iconos y le decimos qué fila seleccionar
    selection=$(echo "$THEME_LIST" | awk '{print $0 "\0icon\x1f'"$ICON"'"}' | rofi -dmenu -i \
    -p "Tema GTK:" \
    -selected-row ${ROW_INDEX:-0} \
    -a ${ROW_INDEX:-0} \
    -theme "$HOME/.config/rofi/RiceSelector.rasi")
    # Si se cierra Rofi o se pulsa ESC, salir del bucle
    if [ -z "$selection" ]; then
        break
    fi

    # 5. Aplicar el tema seleccionado
    xfconf-query -c xsettings -p /Net/ThemeName -s "$selection"
    xfconf-query -c xfwm4 -p /general/theme -s "$selection"

    # 6. Ejecutar Polybar
    if [ -f "$HOME/.config/polybar/polybar.sh" ]; then
        bash "$HOME/.config/polybar/polybar.sh" &

    else
        # Si está en la misma carpeta que este script o en el PATH:
        ./polybar.sh &
    fi
done
