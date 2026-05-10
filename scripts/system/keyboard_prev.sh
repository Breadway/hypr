#!/bin/bash

# Configuration
PREVIEW_CMD="/home/breadway/redox-layout-viewer/target/release/redox-layout-viewer"
APP_NAME="redox-layout-vi"
# The hardware ID for your Redox
ID="4d44:5244"

while true; do
    # Check if the keyboard is physically present
    if lsusb -d "$ID" > /dev/null; then
        # If it's present but the preview isn't running, start it
        if ! pgrep -f "$APP_NAME" > /dev/null; then
            # No need for sudo or env variables because this runs AS YOU
            $PREVIEW_CMD > /dev/null 2>&1 &
        fi
    else
        # If it's NOT present but the preview IS running, kill it
        if pgrep -f "$APP_NAME" > /dev/null; then
            pkill -f "$APP_NAME"
        fi
    fi
    # Check every 0.5 seconds for near-instant response
    sleep 0.5
done