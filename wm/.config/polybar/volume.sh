#!/usr/bin/env bash

# Configuración de archivos y temas
theme="$HOME/.config/rofi/soundManager.rasi"

# Iconos para Rofi
option_1=""
option_2=""
option_3=""
option_4=""
option_5=""

# IDs de notificación (para que se reemplacen a sí mismas y no se acumulen)
NOTIF_VOL=998
NOTIF_MIC=997

SINK="@DEFAULT_SINK@"
SOURCE="@DEFAULT_SOURCE@"

# -------------------------
# Helpers
# -------------------------
get_volume() {
    pactl get-sink-volume "$SINK" | awk -F'/' '{print $2}' | tr -d ' %'
}

is_muted() {
    pactl get-sink-mute "$SINK" | awk '{print $2}' | grep -Eq 'yes|sí'
}

is_mic_muted() {
    pactl get-source-mute "$SOURCE" | awk '{print $2}' | grep -Eq 'yes|sí'
}

volume_icon() {
    local v="$1"
    if (( v <= 30 )); then
        echo "audio-volume-low-symbolic"
    elif (( v <= 70 )); then
        echo "audio-volume-medium-symbolic"
    else
        echo "audio-volume-high-symbolic"
    fi
}

# -------------------------
# Notificaciones
# -------------------------
send_volume_notification() {
    local vol
    vol=$(get_volume)

    if is_muted; then
        notify-send -r "$NOTIF_VOL" \
            -u critical \
            -i audio-volume-muted-symbolic \
            -h int:value:0 \
            -h string:x-canonical-private-synchronous:volume-muted \
            "AUDIO SILENCIADO" \
            "El sonido del sistema está desactivado"
    else
        notify-send -r "$NOTIF_VOL" \
            -u normal \
            -i "$(volume_icon "$vol")" \
            -h int:value:"$vol" \
            -h string:x-canonical-private-synchronous:volume-active \
            "AUDIO ACTIVADO" \
            "Volumen actual: ${vol}%"
    fi
}

send_mic_notification() {
    if is_mic_muted; then
        notify-send -r "$NOTIF_MIC" \
            -u critical \
            -i microphone-sensitivity-muted-symbolic \
            -h string:x-canonical-private-synchronous:mic-muted \
            "MICRÓFONO SILENCIADO" \
            "El micrófono está desactivado"
    else
        notify-send -r "$NOTIF_MIC" \
            -u normal \
            -i microphone-sensitivity-high-symbolic \
            -h string:x-canonical-private-synchronous:mic-active \
            "MICRÓFONO ACTIVADO" \
            "El micrófono está activo"
    fi
}

# -------------------------
# Lógica de argumentos (Para i3/Teclas Multimedia)
# -------------------------
case "$1" in
    --up)
        pactl set-sink-volume "$SINK" +5%
        send_volume_notification
        exit 0
        ;;
    --down)
        pactl set-sink-volume "$SINK" -5%
        send_volume_notification
        exit 0
        ;;
    --mute)
        pactl set-sink-mute "$SINK" toggle
        send_volume_notification
        exit 0
        ;;
    --mic-mute)
        pactl set-source-mute "$SOURCE" toggle
        send_mic_notification
        exit 0
        ;;
esac

# -------------------------
# Loop Rofi (Ejecución normal)
# -------------------------
current_selection=0

while true; do
    vol_val=$(get_volume)

    if is_muted; then
        sicon=""
        prompt="MUTED"
    else
        sicon=""
        prompt="Vol: ${vol_val}%"
    fi

    chosen=$(printf "%s\n%s\n%s\n%s\n%s\n" \
        "$option_1" "$sicon" "$option_3" "$option_4" "$option_5" | \
        rofi -dmenu \
            -p "$prompt" \
            -mesg "Audio Manager" \
            -theme "$theme" \
            -selected-row "$current_selection")

    [[ -z "$chosen" ]] && exit 0

    case "$chosen" in
        "$option_1")
            pactl set-sink-volume "$SINK" +5%
            send_volume_notification
            current_selection=0
            ;;
        "$sicon")
            pactl set-sink-mute "$SINK" toggle
            send_volume_notification
            current_selection=1
            ;;
        "$option_3")
            pactl set-sink-volume "$SINK" -5%
            send_volume_notification
            current_selection=2
            ;;
        "$option_4")
            pactl set-source-mute "$SOURCE" toggle
            send_mic_notification
            current_selection=3
            ;;
        "$option_5")
            pavucontrol &
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
done
