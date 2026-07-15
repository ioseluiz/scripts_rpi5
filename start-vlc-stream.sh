#!/bin/bash
# Lanza VLC en fullscreen reproduciendo el stream UDP.
# Reintenta si VLC se cierra (por ejemplo si el stream se corta temporalmente).
#
# La URL del stream se lee de un archivo de configuracion local (no versionado):
#   $HOME/.config/vlc-stream/stream.conf
# Debe definir la variable STREAM_URL. Ejemplo:
#   STREAM_URL="udp://@IP_DE_TU_RPI:PUERTO"

CONFIG_FILE="$HOME/.config/vlc-stream/stream.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: no existe $CONFIG_FILE" >&2
    echo "Crea el archivo con la variable STREAM_URL. Ver stream.conf.example." >&2
    exit 1
fi

# shellcheck source=/dev/null
. "$CONFIG_FILE"

if [ -z "$STREAM_URL" ]; then
    echo "ERROR: STREAM_URL vacia en $CONFIG_FILE" >&2
    exit 1
fi

# Evita que la pantalla se apague ni entre en modo blanking.
xset s off       2>/dev/null
xset s noblank   2>/dev/null
xset -dpms       2>/dev/null

# Oculta el cursor tras 0.5s de inactividad (opcional, requiere: sudo apt install unclutter).
command -v unclutter >/dev/null && unclutter -idle 0.5 -root &

# Espera hasta que haya red (max 30s) para no arrancar VLC antes que la interfaz este lista.
for i in $(seq 1 30); do
    ip route | grep -q default && break
    sleep 1
done

# Bucle de reintento por si VLC se cierra inesperadamente.
while true; do
    /usr/bin/cvlc \
        --fullscreen \
        --no-video-title-show \
        --no-osd \
        --loop \
        --network-caching=200 \
        --udp-caching=200 \
        --no-audio-time-stretch \
        --qt-continue=0 \
        "$STREAM_URL"
    sleep 2
done
