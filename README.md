# Autostart de VLC en Raspberry Pi 5 (stream UDP en fullscreen)

Scripts para que una Raspberry Pi 5 con Raspberry Pi OS abra automaticamente VLC al iniciar y reproduzca en fullscreen un stream de red (UDP, RTSP, HTTP, etc.) enviado desde otro equipo.

- **Comportamiento:** VLC arranca en fullscreen al entrar al escritorio, sin barra de titulo ni OSD, y se reintenta si se cierra.
- **La URL del stream NO esta en el repositorio.** Se guarda localmente en la Raspberry Pi, en `~/.config/vlc-stream/stream.conf`, y el instalador la pide interactivamente.

## Contenido del repositorio

| Archivo | Descripcion |
| --- | --- |
| `start-vlc-stream.sh` | Lanza `cvlc` en fullscreen. Lee la URL de `~/.config/vlc-stream/stream.conf`, desactiva el screen blanking, espera a que haya red y reintenta si VLC se cierra. |
| `stream.conf.example` | Plantilla del archivo de configuracion. |
| `vlc-stream.desktop` | Entrada de autostart para el escritorio de Raspberry Pi OS. Usa el placeholder `__SCRIPT_PATH__` que el instalador reemplaza. |
| `install.sh` | Instala dependencias, pide la URL, crea `stream.conf`, copia el script al `$HOME` y registra el autostart. |
| `.gitignore` | Excluye `stream.conf` para que la URL nunca se suba al repo. |

## Requisitos

- Raspberry Pi 5 con **Raspberry Pi OS** (Bookworm o superior) con entorno grafico.
- Conexion de red hacia el equipo que emite el stream.
- Acceso `sudo` en la Raspberry Pi.

## Instalacion (paso a paso)

### 1. Clonar el repositorio en la Raspberry Pi

Abre una terminal en la RPi y clona el repositorio en el `$HOME` del usuario:

```bash
cd ~
git clone <URL_DE_TU_REPOSITORIO> rpi5-scripts
cd rpi5-scripts/14_scripts_rpi5
```

> Ajusta la ruta si el repositorio se clona con otra estructura. Lo importante es entrar a la carpeta donde estan `install.sh`, `start-vlc-stream.sh`, `stream.conf.example` y `vlc-stream.desktop`.

### 2. Dar permisos de ejecucion

```bash
chmod +x install.sh start-vlc-stream.sh
```

### 3. Ejecutar el instalador

```bash
./install.sh
```

El instalador hace lo siguiente:

1. `sudo apt-get update` + instala `vlc` y `unclutter`.
2. **Pide la URL del stream** y la guarda en `~/.config/vlc-stream/stream.conf` con permisos `600`.
3. Copia `start-vlc-stream.sh` a `$HOME/start-vlc-stream.sh` y lo marca ejecutable.
4. Crea `~/.config/autostart/vlc-stream.desktop` apuntando al script.

Ejemplos de URL que puedes ingresar cuando el instalador la pida:

- UDP: `udp://@IP_DE_LA_RPI:PUERTO`
- RTSP: `rtsp://usuario:pass@host:puerto/ruta`
- HTTP: `http://host:puerto/stream`

### 4. Reiniciar

```bash
sudo reboot
```

Al volver a entrar al escritorio, VLC debe abrir automaticamente en fullscreen y comenzar a reproducir el stream configurado.

## Cambiar la URL del stream

Edita directamente el archivo de configuracion local (no versionado):

```bash
nano ~/.config/vlc-stream/stream.conf
```

Ajusta la variable `STREAM_URL="..."`, guarda y reinicia la RPi (`sudo reboot`) o vuelve a lanzar el script manualmente:

```bash
bash ~/start-vlc-stream.sh
```

## Emitir el stream desde la PC (VLC en Windows/Linux)

En la PC que envia el video:

1. `Media` -> `Stream...` (Ctrl+S).
2. Anade el archivo o dispositivo de captura y pulsa `Stream`.
3. En destino elige **UDP (legacy)** y coloca:
   - **Direccion:** IP de la Raspberry Pi (la que uses en `STREAM_URL`).
   - **Puerto:** el que uses en `STREAM_URL`.
4. Marca `Activate Transcoding` si necesitas re-codificar (ej. `Video - H.264 + MP3 (TS)`).
5. Inicia el stream.

## Diagnostico

### VLC no arranca al iniciar

Prueba manualmente para ver errores:

```bash
bash ~/start-vlc-stream.sh
```

Verifica que el autostart se haya creado y apunte al script correcto:

```bash
ls -l ~/.config/autostart/vlc-stream.desktop
cat ~/.config/autostart/vlc-stream.desktop
```

Confirma que la configuracion exista:

```bash
cat ~/.config/vlc-stream/stream.conf
```

### VLC abre pero no llega video

- Comprueba que la RPi recibe paquetes en el puerto configurado (sustituye `PUERTO`):
  ```bash
  sudo apt install -y tcpdump
  sudo tcpdump -i any udp port PUERTO
  ```
- Verifica la IP de la RPi:
  ```bash
  ip -4 addr show
  ```
  Debe coincidir con la IP que usas en `STREAM_URL` (o ajustala en la config).
- Revisa firewall/rutas entre el emisor y la RPi.

### Video entrecortado o con artefactos

Sube el buffer editando `~/start-vlc-stream.sh`:

```bash
--network-caching=500 \
--udp-caching=500 \
```

Valores tipicos: `200` (baja latencia, LAN estable) hasta `1500` (red con jitter).

### La pantalla se apaga sola

El script ya ejecuta `xset s off / -dpms / s noblank`. Si aun asi se apaga en Wayland (Bookworm por defecto), considera editar `/etc/lightdm/lightdm.conf` o instalar `wlr-randr` para gestionar el DPMS de Wayland.

## Desinstalacion

```bash
rm -f ~/.config/autostart/vlc-stream.desktop
rm -f ~/start-vlc-stream.sh
rm -rf ~/.config/vlc-stream
sudo apt-get remove --purge -y vlc unclutter   # opcional
```
