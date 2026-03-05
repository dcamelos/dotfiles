#!/bin/bash

# Directorios de temas
THEMES_DIR_SYS="/usr/share/themes"
THEMES_DIR_USER="$HOME/.themes"
ICON="preferences-desktop-theme"

# Función para listar temas con soporte para GTK3
list_themes() {
    for theme in $(ls "$THEMES_DIR_SYS" "$THEMES_DIR_USER" 2>/dev/null); do
        if [ -d "$THEMES_DIR_SYS/$theme/gtk-3.0" ] || [ -d "$THEMES_DIR_USER/$theme/gtk-3.0" ]; then
            echo "$theme"
        fi
    done | sort -u
}

while true; do
    # 1. Obtener el tema actual desde gsettings (compatible con LXAppearance)
    CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g")
    
    # 2. Generar la lista completa
    THEME_LIST=$(list_themes)
    
    # 3. Encontrar el índice para Rofi
    ROW_INDEX=$(echo "$THEME_LIST" | grep -nx "$CURRENT_THEME" | cut -d: -f1)
    [ -z "$ROW_INDEX" ] && ROW_INDEX=1
    ROW_INDEX=$((ROW_INDEX - 1))

    # 4. Lanzar Rofi
    selection=$(echo "$THEME_LIST" | awk '{print $0 "\0icon\x1f'"$ICON"'"}' | rofi -dmenu -i \
    -p "Tema GTK:" \
    -selected-row ${ROW_INDEX} \
    -theme "$HOME/.config/rofi/RiceSelector.rasi")

    if [ -z "$selection" ]; then
        break
    fi

    # 5. Aplicar el tema seleccionado de forma global
    # Esto actualiza la base de datos de GNOME/GTK que LXAppearance lee
    gsettings set org.gnome.desktop.interface gtk-theme "$selection"
    
    # Forzar actualización en archivos .ini para aplicaciones que no leen gsettings (como en i3 puro)
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$selection/" "$HOME/.config/gtk-3.0/settings.ini"
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=\"$selection\"/" "$HOME/.gtkrc-2.0"

    # 6. Refrescar Polybar o i3
    if [ -f "$HOME/.config/polybar/polybar-i3.sh" ]; then
        bash "$HOME/.config/polybar/polybar-i3.sh" &
    fi
    
    # Opcional: Notificación visual
    notify-send "Tema Aplicado" "Se ha cambiado a: $selection" -i "$ICON"
done
