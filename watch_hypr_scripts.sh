#!/bin/bash

# Directory to watch
WATCH_DIR="./scripts/"

echo "Watching for changes in $WATCH_DIR..."

# Loop indefinitely, watching for modify, create, delete, or move events
##[[ $(pgrep -cf "watch_hypr_scripts.sh") -gt 1 ]] && pgrep -of "watch_hypr_scripts.sh" | xargs kill
inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" --format '%w%f' | while read FILE
do
    echo "Change detected in $FILE. Reloading Hyprland..."
    hyprctl reload
done
