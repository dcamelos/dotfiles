#!/bin/bash

# Directorio donde están las imágenes
TARGET_DIR="/home/david/Imágenes/nuevos/wallpapers/images"

# Entrar al directorio
cd "$TARGET_DIR" || exit

# Contador inicial
count=1

# Iterar sobre archivos (puedes ajustar las extensiones si es necesario)
for file in *.{JPG,jpg,jpeg,PNG,png,webp,gif,GIF}; do
  # Verificar si el archivo existe para evitar errores si la carpeta está vacía
  [ -e "$file" ] || continue

  # Obtener la extensión original del archivo
  ext="${file##*.}"

  # Generar el nuevo nombre con ceros a la izquierda (001, 002...)
  new_name=$(printf "Bg%03d.%s" "$count" "$ext")

  # Renombrar
  mv "$file" "$new_name"

  echo "Renombrado: $file -> $new_name"

  ((count++))
done

echo "¡Listo! Se procesaron $((count - 1)) imágenes."
