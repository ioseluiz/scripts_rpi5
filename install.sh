#!/bin/bash
# Instalador: copia el script y registra el autostart para el usuario actual.
# Uso: bash install.sh

set -e

USER_HOME="$HOME"
AUTOSTART_DIR="$USER_HOME/.config/autostart"
SCRIPT_DEST="$USER_HOME/start-vlc-stream.sh"
DESKTOP_DEST="$AUTOSTART_DIR/vlc-stream.desktop"

SCRIPT_SRC="$(dirname "$(readlink -f "$0")")/start-vlc-stream.sh"
DESKTOP_SRC="$(dirname "$(readlink -f "$0")")/vlc-stream.desktop"

echo "[1/4] Instalando VLC y unclutter si no estan presentes..."
sudo apt-get update
sudo apt-get install -y vlc unclutter

echo "[2/4] Copiando el script a $SCRIPT_DEST"
cp "$SCRIPT_SRC" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"

echo "[3/4] Registrando autostart en $DESKTOP_DEST"
mkdir -p "$AUTOSTART_DIR"
# Reemplaza /home/pi por el HOME real del usuario que ejecuta la instalacion.
sed "s|/home/pi/start-vlc-stream.sh|$SCRIPT_DEST|g" "$DESKTOP_SRC" > "$DESKTOP_DEST"
chmod +x "$DESKTOP_DEST"

echo "[4/4] Listo. Reinicia con: sudo reboot"
