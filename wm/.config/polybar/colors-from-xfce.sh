#!/bin/bash
# Requiere: bc

# 1. Obtener el tema actual
THEME=$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
GTK_DIR="$HOME/.themes/$THEME/gtk-3.0"

[[ ! -d "$GTK_DIR" ]] && GTK_DIR="/usr/share/themes/$THEME/gtk-3.0"
GTK_FILE="$GTK_DIR/gtk.css"
[[ ! -f "$GTK_FILE" ]] && GTK_FILE="$GTK_DIR/gtk-main.css"

# --- 2. CONVERSOR RGBA A HEX ---
rgba_to_hex() {
    local input=$(echo "$1" | tr -d '[:space:]')
    
    if [[ "$input" =~ ^#[A-Fa-f0-9]{6}$ ]]; then
        echo "$input"
        return
    fi

    if [[ "$input" =~ rgb(a?)\(([0-9]+),([0-9]+),([0-9]+),?([0-9.]*)?\) ]]; then
        local r=${BASH_REMATCH[2]}
        local g=${BASH_REMATCH[3]}
        local b=${BASH_REMATCH[4]}
        local a=${BASH_REMATCH[5]}
        local hex_rgb=$(printf "%02x%02x%02x" "$r" "$g" "$b")
        
        if [[ -n "$a" && "$a" != "1" ]]; then
            local alpha_hex=$(printf "%02x" $(echo "scale=0; ($a*255)/1" | bc -l))
            echo "#${alpha_hex}${hex_rgb}"
        else
            echo "#${hex_rgb}"
        fi
    else
        echo "$input"
    fi
}

# --- 3. EXTRACCIÓN RECURSIVA (Resuelve @variables) ---
get_standard_color() {
    local name=$1
    local fallback=$2
    
    # Intentar extraer el valor ignorando líneas comentadas
    local raw_val=$(grep -E "@define-color\s+$name\s+" "$GTK_FILE" | grep -v "/\*" | head -n1 | sed -E "s/.*$name\s+([^;]+);.*/\1/" | xargs)

    # Si es una referencia a otra variable (ej: @bg_color)
    if [[ "$raw_val" =~ ^@ ]]; then
        local ref_name=$(echo "$raw_val" | tr -d '@')
        get_standard_color "$ref_name" "$fallback"
    # Si está vacío, usar fallback
    elif [[ -z "$raw_val" ]]; then
        echo "$fallback"
    else
        # Si es un color real, convertirlo
        rgba_to_hex "$raw_val"
    fi
}

# --- 4. MAPEO DE VARIABLES ---
BG=$(get_standard_color "theme_bg_color" "#222222")
FG=$(get_standard_color "theme_fg_color" "#eeeeee")
BASE=$(get_standard_color "theme_base_color" "#2d2d2d")
SELECTED=$(get_standard_color "theme_selected_bg_color" "#3583ea")
TEXT_SELECTED=$(get_standard_color "theme_selected_fg_color" "#ffffff")
TEXT=$(get_standard_color "theme_text_color" "#ffffff")
SUCCESS=$(get_standard_color "success_color" "#53a93f")
WARNING=$(get_standard_color "warning_color" "#f57900")
ERROR=$(get_standard_color "error_color" "#ff5555")

# Limpieza para window-background (asegurar 6 dígitos eliminando canal alfa si existe)
BG_6DIGITS=$(echo "${BG}" | sed -E 's/#([0-9a-fA-F]{2})([0-9a-fA-F]{6})/#\2/; s/^#//')


BG_CLEAN=$(echo "$BG" | tr -d '#')
BG_6=$(echo "$BG_CLEAN" | sed -E 's/^[0-9a-fA-F]{2}([0-9a-fA-F]{6})$/\1/')

# --- 5. GENERAR ARCHIVO POLYBAR ---
cat <<EOF > ~/.config/polybar/colors.ini
[colors]
; Tema: $THEME
background = #00$BG_6
window-background = #CC$BG_6DIGITS
background-alt = $BASE
foreground = $FG
border-color = $SELECTED
primary = $SELECTED
secondary = $SUCCESS
text = $TEXT_SELECTED
alert = $ERROR
disabled = #707880
aurora-blue = $SELECTED
aurora-green = $SUCCESS
aurora-yellow = $WARNING
aurora-orange = $ERROR
aurora-violet = $SELECTED
EOF

# --- 6. GENERAR ARCHIVO ROFI ---
# Nota: Usamos una variable para el alpha de background-alt (ej: E0 es ~87% opacidad)
ROFI_BG_ALT="${BG}E0"

cat <<EOF > ~/.config/rofi/shared.rasi
* {
    font: "JetBrainsMono NF Bold 9";
    background: #${BG_6}CC;
    background-alt: $ROFI_BG_ALT;
    foreground: $FG;
    selected: $SELECTED;
    active: $SUCCESS;
    urgent: $ERROR;
    text: $TEXT;
}
EOF
