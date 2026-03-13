#!/usr/bin/env bash

# 1. Definimos las carpetas en español
CARPETAS=("$HOME/Documentos" "$HOME/Descargas")

# 2. Generamos la lista de rutas completas (PDF y EPUB)
# Usamos -iname para ignorar mayúsculas/minúsculas
LISTA_COMPLETA=$(find "${CARPETAS[@]}" -type f \( -iname "*.pdf" -o -iname "*.epub" \) 2>/dev/null)

# 3. Rofi con tu tema personalizado
# El flag -theme apunta directamente a tu archivo Clipboard.rasi
SELECCION_NOMBRE=$(echo "$LISTA_COMPLETA" | xargs -I {} basename "{}" | rofi -dmenu -i -p "📖 Libros" -theme "/home/david/.config/rofi/Clipboard.rasi")

# 4. Buscamos la ruta completa del archivo seleccionado y lo abrimos
if [ -n "$SELECCION_NOMBRE" ]; then
  # Filtramos la lista completa para encontrar la ruta que termina en el nombre elegido
  RUTA_FINAL=$(echo "$LISTA_COMPLETA" | grep -F "/$SELECCION_NOMBRE")

  # Abrir con zathura (usamos comillas por si el nombre tiene espacios)
  zathura "$RUTA_FINAL" &
fi
