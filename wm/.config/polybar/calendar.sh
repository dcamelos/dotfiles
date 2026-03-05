#!/usr/bin/env bash

DIR="$HOME/.config/rofi"

TODAY_DAY=$(date +"%-d")
TODAY_MONTH=$(date +"%-m")
TODAY_YEAR=$(date +"%Y")

month=$TODAY_MONTH
year=$TODAY_YEAR

DAYS="Lu\nMa\nMi\nJu\nVi\nSá\nDo"

generate_cells() {
    start_day=$(date -d "$year-$month-1" +"%u")
    last_day=$(date -d "$year-$month-1 +1 month -1 day" +"%d")
    for ((i=1; i<start_day; i++)); do echo ""; done
    for ((d=1; d<=last_day; d++)); do echo "$d"; done
}

calendar_menu() {
    local header
    header=$(date -d "$year-$month-1" +"%B %Y")
    
    local cells
    cells=$(generate_cells)
    local menu=$(printf "%b\n%s" "$DAYS" "$cells")

    # Botones visuales en el área de mensaje
    # Usamos espacios para separarlos
    local buttons="<span alpha='50%'>Alt+H</span> ◄  Anterior    •    Siguiente ► <span alpha='50%'>Alt+L</span>"

    local args=(
        -dmenu 
        -theme "$DIR/calendar.rasi" 
        -p "📅 $header"
        -mesg "$buttons"
        -markup-rows
    )
    
    if [[ "$month" -eq "$TODAY_MONTH" && "$year" -eq "$TODAY_YEAR" ]]; then
        start_day=$(date -d "$year-$month-1" +"%u")
        current_idx=$((6 + start_day + TODAY_DAY - 1))
        args+=(-selected-row "$current_idx")
        args+=(-u "$current_idx")
    fi

    # Mapeamos Alt+H (Atrás) y Alt+L (Adelante)
    # También añadimos Alt+Left y Alt+Right por comodidad
    res=$(printf "%b" "$menu" | rofi "${args[@]}" \
        -kb-custom-1 "Alt+h,Alt+Left" \
        -kb-custom-2 "Alt+l,Alt+Right")
    
    echo $?
}

while true; do
    code=$(calendar_menu)
    case "$code" in
        10) # Anterior
            ((month--))
            [[ $month -lt 1 ]] && month=12 && ((year--)) ;;
        11) # Siguiente
            ((month++))
            [[ $month -gt 12 ]] && month=1 && ((year++)) ;;
        *) exit 0 ;;
    esac
done
