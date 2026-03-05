#!/usr/bin/env bash

theme="$HOME/.config/rofi/lightManager.rasi"

# Iconos Rofi
option_1=""   # subir
option_2=""   # preset
option_3=""   # bajar
option_4="󰒓"   # settings

NOTIF_ID=996   # ID único para brillo

# -------------------------
# Helpers
# -------------------------
get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

brightness_icon() {
    local v="$1"
    if (( v <= 33 )); then
        echo "display-brightness-low-symbolic"
    elif (( v <= 66 )); then
        echo "display-brightness-medium-symbolic"
    else
        echo "display-brightness-high-symbolic"
    fi
}

# -------------------------
# Notificación
# -------------------------
send_notification() {
    local current icon
    current=$(get_brightness)
    icon=$(brightness_icon "$current")

    notify-send -r "$NOTIF_ID" \
        -u low \
        -t 1500 \
        -i "$icon" \
        -h int:value:"$current" \
        -h string:x-canonical-private-synchronous:brightness \
        "BRILLO DE PANTALLA" \
        "Nivel actual: ${current}%"
}

# -------------------------
# Interceptor para Teclas (i3)
# -------------------------
case "$1" in
    --up)
        brightnessctl set +5%
        send_notification
        exit 0
        ;;
    --down)
        brightnessctl set 5%-
        send_notification
        exit 0
        ;;
esac

# -------------------------
# Loop Rofi
# -------------------------
current_selection=0

while true; do
    backlight=$(get_brightness)
    prompt="${backlight}%"

    chosen=$(printf "%s\n%s\n%s\n%s\n" \
        "$option_1" "$option_2" "$option_3" "$option_4" | \
        rofi -dmenu \
            -p "$prompt" \
            -mesg "Ajuste de Brillo" \
            -theme "$theme" \
            -selected-row "$current_selection")

    [[ -z "$chosen" ]] && exit 0

    case "$chosen" in
        "$option_1")
            brightnessctl set +5%
            send_notification
            current_selection=0
            ;;
        "$option_2")
            brightnessctl set 25%
            send_notification
            current_selection=1
            ;;
        "$option_3")
            brightnessctl set 5%-
            send_notification
            current_selection=2
            ;;
        "$option_4")
            xfce4-power-manager-settings &
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
done
