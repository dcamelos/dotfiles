#!/usr/bin/env bash

ancho=4
alto=5
desfase_x=2
desfase_y=1
separacion=5
espacio_inicial=10
marco_color=7

echo -e "\n"
IFS='[;' read -p $'\e[6n' -d R -rs _ line col

for i in {0..7}; do

  pos_x=$((espacio_inicial + (i * (ancho + separacion))))

  # --- MARCO FINO para Color 0 ---

  if [ $i -eq 0 ]; then

    # Color del texto (38) para que la línea sea delgada

    # Esquina superior

    printf "\e[${line};$((pos_x - 1))H\e[38;5;${marco_color}m┌$(printf '─%.0s' $(seq 1 $ancho))┐\e[0m"

    # Laterales

    for ((l = 1; l < alto; l++)); do

      printf "\e[$((line + l));$((pos_x - 1))H\e[38;5;${marco_color}m│\e[$((ancho))C│\e[0m"

    done

    # Esquina inferior

    printf "\e[$((line + alto));$((pos_x - 1))H\e[38;5;${marco_color}m└$(printf '─%.0s' $(seq 1 $ancho))┘\e[0m"

  fi

  # --- BARRA ATRÁS ---

  for ((l = 0; l < alto; l++)); do

    # Se dibuja encima del marco, dejando ver solo los bordes laterales

    printf "\e[$((line + l));$((pos_x + 1))H\e[48;5;${i}m%*s\e[0m" $ancho ""

  done

  # --- BARRA ADELANTE ---

  for ((l = 0; l < alto; l++)); do

    printf "\e[$((line + l + desfase_y));$((pos_x + 1 + desfase_x))H\e[48;5;$((i + 8))m%*s\e[0m" $ancho ""

  done

done

printf "\e[$((line + alto + desfase_y + 1));1H\n"
