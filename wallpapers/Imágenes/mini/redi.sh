#!/bin/bash

# Directorio de las miniaturas
TARGET_DIR="$HOME/Imágenes/mini"

# Verificar si el directorio existe
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: El directorio $TARGET_DIR no existe."
  exit 1
fi

echo "Procesando imágenes en $TARGET_DIR..."

# Recorrer archivos con extensiones comunes (ignorar mayúsculas/minúsculas)
shopt -s nocaseglob

for img in "$TARGET_DIR"/*.{jpg,jpeg,png,webp,JPG,PNG,JPEG}; do
  # Verificar si el archivo existe (por si la carpeta está vacía)
  [ -e "$img" ] || continue

  echo "Redimensionando: $(basename "$img")"

  # Aplicar la transformación de ImageMagick sobre el mismo archivo
  # -resize 889x500^ asegura que la imagen cubra todo el área
  # -gravity center centra el recorte:
  # -extent 889x500 recorta el exceso para dejar la medida exacta
  magick "$img" -resize 500x800^ -gravity center -extent 500x800 "$img"

done

shopt -u nocaseglob

echo "¡Listo! Todas las imágenes han sido ajustadas a tarjeta"
