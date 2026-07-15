#!/bin/bash
# Instalador: copia el script, pide la URL del stream y registra el autostart.
# Uso: bash install.sh

set -e

USER_HOME="$HOME"
AUTOSTART_DIR="$USER_HOME/.config/autostart"
CONFIG_DIR="$USER_HOME/.config/vlc-stream"
CONFIG_FILE="$CONFIG_DIR/stream.conf"
SCRIPT_DEST="$USER_HOME/start-vlc-stream.sh"
DESKTOP_DEST="$AUTOSTART_DIR/vlc-stream.desktop"

REPO_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_SRC="$REPO_DIR/start-vlc-stream.sh"
DESKTOP_SRC="$REPO_DIR/vlc-stream.desktop"
CONFIG_SRC="$REPO_DIR/stream.conf.example"

echo "[1/5] Instalando VLC y unclutter si no estan presentes..."
sudo apt-get update
sudo apt-get install -y vlc unclutter

echo "[2/5] Configurando la URL del stream en $CONFIG_FILE"
mkdir -p "$CONFIG_DIR"
if [ -f "$CONFIG_FILE" ]; then
    echo "  Ya existe una configuracion. Se conserva. Editala manualmente si quieres cambiarla."
else
    read -r -p "  Ingresa la URL del stream (formato: udp://@IP:PUERTO): " USER_STREAM_URL
    if [ -z "$USER_STREAM_URL" ]; then
        echo "ERROR: URL vacia. Aborto." >&2
        exit 1
    fi
    # Genera el archivo de configuracion a partir del ejemplo.
    sed "s|^STREAM_URL=.*|STREAM_URL=\"$USER_STREAM_URL\"|" "$CONFIG_SRC" > "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

echo "[3/5] Copiando el script a $SCRIPT_DEST"
cp "$SCRIPT_SRC" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"

echo "[4/5] Registrando autostart en $DESKTOP_DEST"
mkdir -p "$AUTOSTART_DIR"
# Sustituye la ruta placeholder del .desktop por la ruta real del script instalado.
sed "s|__SCRIPT_PATH__|$SCRIPT_DEST|g" "$DESKTOP_SRC" > "$DESKTOP_DEST"
chmod +x "$DESKTOP_DEST"

echo "[5/5] Listo. Reinicia con: sudo reboot"
