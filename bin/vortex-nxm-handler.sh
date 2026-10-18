#!/bin/bash
NXM_URL="$1"
export WINEPREFIX='/mnt/games/chaos/chaos/default'
export GAMEID='default'
export PROTONPATH='/home/df/.local/share/Steam/compatibilitytools.d/GE-Proton10-13'
VORTEX_EXE="/mnt/games/NexusModsArchives/vortex/drive_c/Program Files/Black Tree Gaming Ltd/Vortex/Vortex.exe"

# Try using start /ProgID style which is sometimes better for IPC
/home/df/.local/share/faugus-launcher/umu-run wine start 'C:\Program Files\Black Tree Gaming Ltd\Vortex\Vortex.exe' -d "$1"
