#!/bin/bash
# Requiere: bc

# 1. Obtener el tema actual desde el archivo de configuración de GTK3 (el que usa LXAppearance)
THEME=$(grep "gtk-theme-name" "$HOME/.config/gtk-3.0/settings.ini" | cut -d'=' -f2 | tr -d '[:space:]')

# Si por alguna razón está vacío, intentar gsettings
if [ -z "$THEME" ]; then
    THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
fi

echo "Tema detectado: $THEME"

# Buscar el directorio del tema
if [ -d "$HOME/.themes/$THEME/gtk-3.0" ]; then
    GTK_DIR="$HOME/.themes/$THEME/gtk-3.0"
elif [ -d "/usr/share/themes/$THEME/gtk-3.0" ]; then
    GTK_DIR="/usr/share/themes/$THEME/gtk-3.0"
else
    echo "Error: No se encontró el directorio del tema $THEME"
    exit 1
fi
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
    local raw_val=$(grep -rE "@define-color\s+$name\s+" "$GTK_DIR" | head -n1 | sed -E "s/.*$name\s+([^;]+);.*/\1/" | xargs)
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
    font: " BebasNeue 14";
    background: #${BG_6}CC;
    background-alt: $ROFI_BG_ALT;
    foreground: $FG;
    selected: $SELECTED;
    active: $SUCCESS;
    urgent: $ERROR;
    text: $TEXT;
}
EOF

# Actualizar el tema en gsettings (para apps GTK3 como Thunar moderno)
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"

# Actualizar el archivo de configuración de xsettingsd para que los cambios sean instantáneos
echo "Net/ThemeName \"$THEME\"" > ~/.xsettingsd
killall -HUP xsettingsd 2>/dev/null || xsettingsd &

# --- 7. GENERAR ARCHIVO DUNST ---
# Creamos el directorio si no existe
mkdir -p ~/.config/dunst

cat <<EOF > ~/.config/dunst/dunstrc
[global]
  # Defines where the notifications should be placed in a multi-monitor setup
  follow = keyboard

   # Fixed width of a notification
  width = 400

  # Maximum height of a single notification
  height = 300

  # Origin of the notification window on the screen
  origin = top-right

  # Offset from the origin
  offset = 20x50

  # When an integer value is passed to dunst as a hint, a progress bar will be drawn at the bottom of the notification
  progress_bar = true

  # Set the progress bar height
  progress_bar_height = 18

  # Set the frame width of the progress bar
  progress_bar_frame_width = 0

  # Set the minimum width of the progress bar
  progress_bar_min_width = 150

  # Set the maximum width of the progress bar
  progress_bar_max_width = 350

  # Set the corner radius of the progress bar
  progress_bar_corner_radius = 14

  # Vertical padding
  padding = 16

  # Horizontal padding
  horizontal_padding = 16

  # The distance from the text to the icon
  text_icon_padding = 16

  # Width of frame around the notification window
  frame_width = 2

  # Size of gap to display between notifications
  gap_size = 12

  font = BebasNeue 14

  # The amount of extra spacing between text lines in pixels
  line_height = 1.5

  # Format of the message (<b> bold tag, %s notification summary, %b notification body, \n new line)
  format = "<b>%s</b>\n%b"

  # Stack together notifications with the same content
  stack_duplicates = true

  # Don't hide the count of stacked notifications with the same content
  hide_duplicate_count = true

  # Show an indicator if a notification contains actions and/or open-able URLs
  show_indicators = false

  # This setting enables the new icon lookup method (required for icon_theme)
  enable_recursive_icon_lookup = true

  # Set icon theme (only used for recursive icon lookup)
  icon_theme = "Everforest-Dark, Papirus-Dark, Adwaita"

  min_icon_size = 32
  max_icon_size = 96
  icon_corner_radius = 10

  # Maximum amount of notifications kept in history
  history_length = 100

  # Define the title of the windows spawned by dunst
  title = Dunst

  # Define the class of the windows spawned by dunst
  class = Dunst

  # Define the corner radius of the notification window
  corner_radius = 20

[urgency_low]
    background = "$BG"
    foreground = "$FG"
    timeout = 5

[urgency_normal]
    background = "$BG"
    foreground = "$FG"
    frame_color = "$SELECTED"
    timeout = 10

[urgency_critical]
    background = "$ERROR"
    foreground = "$BG"
    frame_color = "$BG"
    timeout = 0
EOF

# Reiniciar Dunst para aplicar cambios
killall dunst
dunst &

# --- 8. GENERAR ARCHIVO EWW (SCSS) ---
# Creamos el archivo de variables para eww
cat <<EOF > ~/.config/eww/colors.scss
// Colores generados automáticamente desde el tema: $THEME
\$bg: $BG;
\$bg-alt: $BASE;
\$fg: $FG;
\$black: #414868;
\$lightblack: #262831;
\$red: #f7768e;
\$blue: #7aa2f7;
\$cyan: #7dcfff;
\$magenta: #bb9af7;
\$green: #9ece6a;
\$yellow: #e0af68;
\$archicon: #0f94d2;
\$border: $SELECTED; 
EOF

echo "Colores exportados a eww/colors.scss"

# --- 9. GENERAR TEMA PARA HELIX ---
# El archivo se llamará "gtk_theme.toml"
cat <<EOF > "$HOME/.config/helix/themes/gtk_theme.toml"
# Tema generado automáticamente basado en: $THEME

# --- INTERFAZ DE USUARIO ---
"ui.background" = { }
"ui.text" = { fg = "$FG" }
"ui.window" = { fg = "$BASE" }
"ui.help" = { bg = "$BASE", fg = "$FG" }

"ui.statusline" = { fg = "$FG", bg = "$BASE" }
"ui.statusline.inactive" = { fg = "#707880", bg = "$BG" }
"ui.statusline.normal" = { fg = "$BG", bg = "$SELECTED", modifiers = ["bold"] }
"ui.statusline.insert" = { fg = "$BG", bg = "$SUCCESS", modifiers = ["bold"] }
"ui.statusline.select" = { fg = "$BG", bg = "$WARNING", modifiers = ["bold"] }

"ui.virtual.indent-guide" = { fg = "$BASE" }
"ui.virtual.inlay-hint" = { fg = "#707880" }

"ui.selection" = { bg = "$SELECTED" }
"ui.cursor" = { fg = "$BG", bg = "$FG" }
"ui.cursor.match" = { fg = "$SELECTED", modifiers = ["underline"] }

"ui.menu" = { fg = "$FG", bg = "$BASE" }
"ui.menu.selected" = { fg = "$TEXT_SELECTED", bg = "$SELECTED" }
"ui.popup" = { bg = "$BASE" }
"ui.linenr" = { fg = "#707880" }
"ui.linenr.selected" = { fg = "$SELECTED", modifiers = ["bold"] }

# --- SINTAXIS (Mapeo de lógica de colores) ---
"keyword" = "$SELECTED"
"variable" = "$FG"
"variable.parameter" = "$FG"
"function" = "$SELECTED"
"string" = "$SUCCESS"
"constant" = "$WARNING"
"type" = "$WARNING"
"comment" = { fg = "#707880", modifiers = ["italic"] }
"operator" = "$SELECTED"
"punctuation" = "#707880"

# Diagnósticos
"error" = "$ERROR"
"warning" = "$WARNING"
"info" = "$SELECTED"
"hint" = "$SUCCESS"

[palette]
# Colores base para uso rápido
theme_bg = "$BG"
theme_fg = "$FG"
accent = "$SELECTED"
EOF

echo "Archivo de Helix actualizado en themes/gtk_theme.toml"
