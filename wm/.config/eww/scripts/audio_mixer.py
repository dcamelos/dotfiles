#!/usr/bin/env python3
import subprocess
import json
import sys

def get_player_metadata():
    players_info = {}
    try:
        players = subprocess.check_output(["playerctl", "-l"], stderr=subprocess.DEVNULL).decode().splitlines()
        for player in players:
            try:
                title = subprocess.check_output(["playerctl", "-p", player, "metadata", "title"], stderr=subprocess.DEVNULL).decode().strip()
                artist = subprocess.check_output(["playerctl", "-p", player, "metadata", "artist"], stderr=subprocess.DEVNULL).decode().strip()
                status = subprocess.check_output(["playerctl", "-p", player, "status"], stderr=subprocess.DEVNULL).decode().strip().lower()
                
                full_name = f"{artist} - {title}" if artist and title else title
                clean_name = player.split('.')[0].lower()
                
                if clean_name not in players_info or status == "playing":
                    players_info[clean_name] = {
                        "title": full_name, 
                        "status": status,
                        "full_player_id": player 
                    }
            except: continue
    except: pass
    return players_info

def get_audio_clients():
    mpris_data = get_player_metadata()
    
    # wmctrl -lx nos da la CLASE de la ventana (ej: firefox.Firefox)
    windows = []
    try:
        w_out = subprocess.check_output(["wmctrl", "-lx"]).decode().splitlines()
        for line in w_out:
            parts = line.split(None, 4)
            if len(parts) >= 5:
                windows.append({
                    "id": parts[0], 
                    "class": parts[2].lower(), 
                    "title": parts[4].lower()
                })
    except: pass

    try:
        output = subprocess.check_output(["pactl", "--format=json", "list", "sink-inputs"]).decode()
        pa_data = json.loads(output)
        if not isinstance(pa_data, list): pa_data = [pa_data]
    except: return []

    clients = []
    for item in pa_data:
        props = item.get('properties', {})
        binary = props.get('application.process.binary', "").lower()
        clean_bin = binary.replace("-bin", "")
        
        info = mpris_data.get(clean_bin, {})
        display_name = info.get("title", "")
        
        if not display_name or not display_name.strip():
            display_name = props.get('media.title') or props.get('application.name') or clean_bin.capitalize()

        # LÓGICA DE ENFOQUE MEJORADA
        search_target = binary
        found = False
        
        # 1. Intentar match por título del video (Lo más preciso para WebApps)
        for w in windows:
            if display_name.lower()[:15] in w['title']:
                search_target = w['id']
                found = True
                break
        
        # 2. Si falla, intentar match por clase de ventana (Firefox/Brave)
        if not found:
            for w in windows:
                if clean_bin in w['class']:
                    search_target = w['id']
                    break
        
        vol_data = item.get('volume', {})
        volume = int(list(vol_data.values())[0].get('value_percent', '0%').strip('%')) if vol_data else 0

        clients.append({
            "id": item['index'],
            "name": display_name[:35].upper(), 
            "search_name": search_target, 
            "player_name": info.get("full_player_id", clean_bin),
            "status": info.get("status", "playing"),
            "volume": volume,
            "mute": item.get('mute', False)
        })
    return clients

def focus_window(target):
    # Intentamos enfocar usando el ID directamente (-i) que es lo más seguro
    try:
        if target.startswith("0x"):
            subprocess.run(["wmctrl", "-i", "-a", target])
        else:
            # Si es un nombre de app, intentamos enfoque normal
            subprocess.run(["wmctrl", "-a", target])
    except: pass

if __name__ == "__main__":
    if len(sys.argv) > 1:
        action = sys.argv[1]
        try:
            if action == "--focus-app": focus_window(sys.argv[2])
            elif action == "--set-vol": subprocess.run(["pactl", "set-sink-input-volume", sys.argv[2], f"{sys.argv[3]}%"])
            elif action == "--toggle-mute": subprocess.run(["pactl", "set-sink-input-mute", sys.argv[2], "toggle"])
            elif action == "--toggle-play": subprocess.run(["playerctl", "-p", sys.argv[2], "play-pause"])
        except: pass
    else:
        print(json.dumps(get_audio_clients()))
