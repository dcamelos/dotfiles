#!/usr/bin/env bash

ancho=4
alto=5
desfase_x=2
desfase_y=1
separacion=5
espacio_inicial=10

echo -e "\n"
IFS='[;' read -p $'\e[6n' -d R -rs _ line col

for i in {0..7}; do
  pos_x=$((espacio_inicial + (i * (ancho + separacion))))

  # Si el color es 0, usamos el 237 para que no desaparezca en el fondo negro
  col_back=$i
  [[ $i -eq 0 ]] && col_back=237

  # --- BARRA ATRÁS ---
  for ((l = 0; l < alto; l++)); do
    printf "\e[$((line + l));$((pos_x))H\e[48;5;${col_back}m%*s\e[0m" $ancho ""
  done

  # --- BARRA ADELANTE ---
  for ((l = 0; l < alto; l++)); do
    printf "\e[$((line + l + desfase_y));$((pos_x + desfase_x))H\e[48;5;$((i + 8))m%*s\e[0m" $ancho ""
  done
done

printf "\e[$((line + alto + desfase_y + 1));1H\n"
