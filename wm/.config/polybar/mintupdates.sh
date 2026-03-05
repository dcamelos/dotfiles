#!/bin/bash

# Ruta al archivo de colores
COLOR_FILE="$HOME/.config/polybar/colors.ini"

# Función para obtener el color del archivo .ini
get_color() {
    grep "^$1" "$COLOR_FILE" | cut -d'=' -f2 | tr -d ' '
}

# Colores (con fallback por si el archivo no carga rápido)
green=$(get_color "aurora-green")
yellow=$(get_color "aurora-yellow")
red=$(get_color "aurora-orange")
green=${green:-#a3be8c} 

# --- Verificación de Conexión ---
# Si no hay internet, salimos rápido y mostramos un aviso limpio
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "%{F$yellow}󰚵 offline%{F-}"
    
    exit 0
fi

# --- Conteo de actualizaciones ---

# 1. Mint Update (Redirigimos errores a /dev/null)
updates_mint=$(mintupdate-cli list 2>/dev/null | grep -c "^update")

# 2. APT 
updates_apt=$(apt-get -s upgrade 2>/dev/null | grep -c "^Inst")

# 3. Flatpak (Redirigimos errores por si el servidor no responde)
if command -v flatpak &> /dev/null; then
    updates_flatpak=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
else
    updates_flatpak=0
fi

# Suma total
total_updates=$((updates_mint + updates_apt + updates_flatpak))

# --- Lógica de colores ---
if [ "$total_updates" -eq 0 ]; then
    color="$green"
elif [ "$total_updates" -le 10 ]; then
    color="$yellow"
else
    color="$red"
fi

# --- Lógica para la notificación ---
if [ "$1" == "--notify" ]; then
    RESUMEN="Suministros: $updates_mint\nSistema (APT): $updates_apt\nFlatpak: $updates_flatpak"
    notify-send "Estado de actualizaciones" "$RESUMEN" -i software-update-available
fi

# Salida para Polybar
echo -e "%{F$color}%{T4}%{T-} : $total_updates%{F-}"
