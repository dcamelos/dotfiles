#!/bin/bash

LAST_STATE="show"

while true; do
    WINDOW_ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')
    
    if [[ "$WINDOW_ID" != "0x0" && -n "$WINDOW_ID" ]]; then
        if xprop -id "$WINDOW_ID" _NET_WM_STATE | grep -q "_NET_WM_STATE_FULLSCREEN"; then
            CURRENT_STATE="hide"
        else
            CURRENT_STATE="show"
        fi

        # SOLO envía el comando si el estado cambió
        if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
            polybar-msg cmd "$CURRENT_STATE" > /dev/null 2>&1
            LAST_STATE="$CURRENT_STATE"
        fi
    fi
    sleep 0.5
done
