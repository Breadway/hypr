#!/bin/bash

# Directory to watch
WATCH_DIR="./scripts/"

echo "Watching for changes in $WATCH_DIR..."

# Loop indefinitely, watching for modify, create, delete, or move events
inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" --format '%w%f' | while read FILE
do
    echo "Change detected in $FILE. Reloading Hyprland..."
    hyprctl reload
done
