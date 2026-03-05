#!/usr/bin/env bash

# Ruta a tu archivo de estilo
theme="$HOME/.config/rofi/powermenu.rasi"

# CMDs para obtener info del sistema
uptime="$(uptime -p | sed -e 's/up //g')"
user="$(whoami)"

# Iconos/Opciones (Asegúrate de tener una Nerd Font instalada)
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD: Aquí es donde se pasa el mensaje de Uptime y la Despedida
rofi_cmd() {
    rofi -dmenu \
        -p "Goodbye $user" \
        -mesg "Uptime: $uptime" \
        -theme "$theme"
}

# CMD de confirmación (Usa el mismo tema o uno genérico)
confirm_cmd() {
    rofi -dmenu \
        -p '¿Estás seguro?' \
        -mesg 'Se cerrarán todas las aplicaciones' \
        -theme "$theme"
}

# Lógica de ejecución
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

case "$(run_rofi)" in
    $shutdown)
        ans=$(echo -e "$yes\n$no" | confirm_cmd)
        [ "$ans" == "$yes" ] && systemctl poweroff
        ;;
    $reboot)
        ans=$(echo -e "$yes\n$no" | confirm_cmd)
        [ "$ans" == "$yes" ] && systemctl reboot
        ;;
    $lock)
        # Intenta usar i3lock si está disponible
        i3lock || xfce4-screensaver-command -l
        ;;
    $suspend)
        ans=$(echo -e "$yes\n$no" | confirm_cmd)
        [ "$ans" == "$yes" ] && systemctl suspend
        ;;
    $logout)
        ans=$(echo -e "$yes\n$no" | confirm_cmd)
        [ "$ans" == "$yes" ] && i3-msg exit
        ;;
esac
