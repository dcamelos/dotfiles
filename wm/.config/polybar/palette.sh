#!/usr/bin/env bash

# Margen izquierdo para que no pegue al borde de la terminal
margin="      "

# Primera fila de bloques (Colores 0-7)
echo -e "\n" # Espacio superior
printf "$margin"
for i in {0..7}; do
    # Imprime el bloque y luego dos espacios de separación
    printf "\e[48;5;%sm    \e[0m  " $i
done
printf "\n"

# Segunda fila de bloques (Colores 8-15)
printf "$margin"
for i in {8..15}; do
    # Imprime el bloque brillante y luego dos espacios de separación
    printf "\e[48;5;%sm    \e[0m  " $i
done
echo -e "\n" # Espacio inferior
