#!/bin/bash

WATCH_DIR="$(dirname "$(realpath "$0")")/scripts/"

echo "Watching for changes in $WATCH_DIR..."

inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" --format '%w%f' | while read FILE
do
    echo "Change detected in $FILE. Reloading Hyprland..."
    hyprctl reload
done
