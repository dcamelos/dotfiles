#!/bin/bash

# 1. Obtener el Bitrate
BITRATE=$(iw dev wlp2s0 link | grep 'tx bitrate' | awk '{print $3}')

# 2. Obtener la potencia de señal (de 0 a 70 suele ser el rango de iw)
# Extraemos el valor de 'signal' y lo convertimos a un porcentaje aproximado
SIGNAL_DBM=$(iw dev wlp2s0 link | grep 'signal' | awk '{print $2}')

if [ -z "$BITRATE" ]; then
    echo  "%{T4}󰤮 %{T-}Offline"
else
    # Lógica para elegir el icono según la potencia (dBm)
    # Valores típicos: -30 (excelente) a -80 (pobre)
    if [ "$SIGNAL_DBM" -ge -50 ]; then
        ICON="%{T4}󰤨%{T-}"  # Excelente
    elif [ "$SIGNAL_DBM" -ge -60 ]; then
        ICON="%{T4}󰤥%{T-}"  # Buena
    elif [ "$SIGNAL_DBM" -ge -70 ]; then
        ICON="%{T4}󰤢%{T-}"  # Regular
    elif [ "$SIGNAL_DBM" -ge -80 ]; then
        ICON="%{T4}󰤟%{T-}"  # Mala
    else
        ICON="%{T4}󰤯%{T-}"  # Muy mala
    fi

    # Resultado: Icono + Bitrate redondeado
    echo "$ICON ${BITRATE%.*} Mb/s"
    # echo "$ICON ${BITRATE%.*}K"

fi
