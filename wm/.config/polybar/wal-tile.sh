#!/bin/bash

# Comprobar si se pasó una imagen
if [ -z "$1" ]; then
  echo "Error: Debes proporcionar una imagen."
  echo "Uso: $0 /ruta/a/la/imagen.jpg"
  exit 1
fi

# 1. Generar colores con Pywal
# -n: evita que wal cambie el fondo (lo haremos nosotros si prefieres)
# -q: modo silencioso
wal -i "$1"

# 2. Cargar las variables de colores recién generadas
source "$HOME/.cache/wal/colors.sh"

# --- 3. EXPORTAR A CONFIGURACIONES ---

# Polybar

# Extraemos el color de fondo sin el '#'
BG_HEX=$(echo "$background" | sed 's/#//')

cat <<EOF >~/.config/polybar/colors.ini
[colors]
background = #00${BG_HEX}
window-background = #CC${background:1}
background-alt = ${color8}
foreground = ${foreground}
border-color = ${color4}
primary = ${color4}
secondary = ${color2}
text = ${foreground}
alert = ${color1}
disabled = #707880

 
aurora-blue = ${color4}
aurora-green = ${color2}
aurora-yellow = ${color3}
aurora-orange =  ${color1}
aurora-violet = ${color4}

EOF

# Rofi
# cat <<EOF >~/.config/rofi/shared.rasi
# * {
#     font: " BebasNeue 14";
#     background: ${background}CC;
#     background-alt: ${background}E0;
#     foreground: ${foreground};
#     selected: ${color4};
#     active: ${color2};
#     urgent: ${color1};
#     text:  ${foreground};
# }
# EOF

# Dunst
mkdir -p ~/.config/dunst

# Primero borra el archivo actual si ya existe
rm ~/.dotfiles/wm/.config/dunst/dunstrc

# Crea el enlace simbólico
cp ~/.cache/wal/dunstrc ~/.dotfiles/wm/.config/dunst/dunstrc

# cat <<EOF >~/.config/dunst/dunstrc
# [global]
#   # Defines where the notifications should be placed in a multi-monitor setup
#   follow = keyboard
#
#    # Fixed width of a notification
#   width = 400
#
#   # Maximum height of a single notification
#   height = 300
#
#   # Origin of the notification window on the screen
#   origin = top-right
#
#   # Offset from the origin
#   offset = 20x50
#
#   # When an integer value is passed to dunst as a hint, a progress bar will be drawn at the bottom of the notification
#   progress_bar = true
#
#   # Set the progress bar height
#   progress_bar_height = 18
#
#   # Set the frame width of the progress bar
#   progress_bar_frame_width = 0
#
#   # Set the minimum width of the progress bar
#   progress_bar_min_width = 150
#
#   # Set the maximum width of the progress bar
#   progress_bar_max_width = 350
#
#   # Set the corner radius of the progress bar
#   progress_bar_corner_radius = 14
#
#   # Vertical padding
#   padding = 16
#
#   # Horizontal padding
#   horizontal_padding = 16
#
#   # The distance from the text to the icon
#   text_icon_padding = 16
#
#   # Width of frame around the notification window
#   frame_width = 2
#
#   # Size of gap to display between notifications
#   gap_size = 12
#
#   font = BebasNeue 14
#
#   # The amount of extra spacing between text lines in pixels
#   line_height = 1.5
#
#   # Format of the message (<b> bold tag, %s notification summary, %b notification body, \n new line)
#   format = "<b>%s</b>\n%b"
#
#   # Stack together notifications with the same content
#   stack_duplicates = true
#
#   # Don't hide the count of stacked notifications with the same content
#   hide_duplicate_count = true
#
#   # Show an indicator if a notification contains actions and/or open-able URLs
#   show_indicators = false
#
#   # This setting enables the new icon lookup method (required for icon_theme)
#   enable_recursive_icon_lookup = true
#
#   # Set icon theme (only used for recursive icon lookup)
#   icon_theme = "Everforest-Dark, Papirus-Dark, Adwaita"
#
#   min_icon_size = 32
#   max_icon_size = 96
#   icon_corner_radius = 10
#
#   # Maximum amount of notifications kept in history
#   history_length = 100
#
#   # Define the title of the windows spawned by dunst
#   title = Dunst
#
#   # Define the class of the windows spawned by dunst
#   class = Dunst
#
#   # Define the corner radius of the notification window
#   corner_radius = 0 #20
#
# highlight = "${color2}"
#
# [urgency_low]
#     background = "${background}"
#     foreground = "${foreground}"
# [urgency_normal]
#     background = "${background}"
#     foreground = "${foreground}"
#     frame_color = "${color4}"
# [urgency_critical]
#     background = "${color1}"
#     foreground = "${background}"
# EOF

# --- 9. GENERAR TEMA PARA HELIX ---
# El archivo se llamará "gtk_theme.toml"
cat <<EOF >"$HOME/.config/helix/themes/gtk_theme.toml"
# --- INTERFAZ DE USUARIO ---
"ui.background" = { }
"ui.text" = { fg = "${foreground}"}
"ui.window" = { fg = "${color8}" }
"ui.help" = { bg = "${color8}", fg = "${foreground}"}

"ui.statusline" = { fg = "${foreground}", bg = "${color8}" }
"ui.statusline.inactive" = { fg = "#707880", bg = "${background}"}
"ui.statusline.normal" = { fg = "${background}", bg = "${color4}", modifiers = ["bold"] }
"ui.statusline.insert" = { fg = "${background}", bg = "${color2}", modifiers = ["bold"] }
"ui.statusline.select" = { fg = "${background}", bg = "${color3}", modifiers = ["bold"] }

"ui.virtual.indent-guide" = { fg = "${color8}" }
"ui.virtual.inlay-hint" = { fg = "#707880" }

# --- SOLUCIÓN AL CONTRASTE ---
"ui.selection" = { fg = "${background}", bg = "${color4}" }
"ui.selection.primary" = { fg = "${background}", bg = "${color6}" } # Un color distinto para la selección principal
"ui.cursor" = { fg = "${background}", bg = "${foreground}"}
"ui.cursor.match" = { fg = "${color4}", modifiers = ["underline"] }

"ui.menu" = { fg = "${foreground}", bg = "${color8}" }
"ui.menu.selected" = { fg = "${background}", bg = "${color4}" }
"ui.popup" = { bg = "${color8}" }
"ui.linenr" = { fg = "#707880" }
"ui.linenr.selected" = { fg = "${color4}", modifiers = ["bold"] }

# --- SINTAXIS (Mapeo de lógica de colores) ---
"keyword" = "${color4}"
"variable" = "${foreground}"
"variable.parameter" = "${foreground}"
"function" = "${color4}"
"string" = "${color2}"
"constant" = "${color3}"
"type" = "${color3}"
"comment" = { fg = "#707880", modifiers = ["italic"] }
"operator" = "${color4}"
"punctuation" = "#707880"

# Diagnósticos
"error" = "${color1}"
"warning" = "${color3}"
"info" = "${color4}"
"hint" = "${color2}"

[palette]
# Colores base para uso rápido
theme_bg = "${background}"
theme_fg = "${foreground}"
accent = "${color4}"
EOF

echo "Archivo de Helix actualizado en themes/gtk_theme.toml"

# --- 4. REINICIAR COMPONENTES ---

# 1. Reiniciar Dunst (en una subshell para que no bloquee)
(
  killall -q dunst
  while pgrep -u $UID -x dunst >/dev/null; do sleep 0.1; done
  dunst &
  sleep 0.3
  notify-send -u normal -r 9999 -t 5000 -i "$1" "🎨 Tema Actualizado" "Esquema de colores aplicado"
) &

# 2. Reiniciar Polybar (independiente del resto)
(
  killall -q polybar
  while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done
  # IMPORTANTE: Asegúrate de que el nombre de la barra sea 'main' o cámbialo aquí
  polybar -c ~/.config/polybar/config.ini main &>/dev/null &
) &

# En tu script de colores:
wal -i "$1"
xrdb -merge "$HOME/.cache/wal/colors.Xresources" # Forzar actualización de base de datos X11
i3-msg reload
echo "Componentes reiniciados en segundo plano."
