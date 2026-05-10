#!/usr/bin/env bash
set -eu

# Configuration from watch-display.sh
home="${HOME:-/home/breadway}"
sync_script="$home/.config/hypr/scripts/system/sync-display.lua"
internal_connector="eDP-1"
lid_inhibit_pid=""
last_sync_ts=0

# Configuration from keyboard_prev.sh
PREVIEW_CMD="/home/breadway/redox-layout-viewer/target/release/redox-layout-viewer"
APP_NAME="redox-layout-vi"
ID="4d44:5244" # The hardware ID for your Redox

# Function to manage redox-layout-viewer based on keyboard presence
manage_redox_viewer() {
    if lsusb -d "$ID" > /dev/null; then
        # If it's present but the preview isn't running, start it
        if ! pgrep -f "$APP_NAME" > /dev/null; then
            $PREVIEW_CMD > /dev/null 2>&1 &
        fi
    else
        # If it's NOT present but the preview IS running, kill it
        if pgrep -f "$APP_NAME" > /dev/null; then
            pkill -f "$APP_NAME"
        fi
    fi
}

# Functions from watch-display.sh
current_state() {
    for status_file in /sys/class/drm/*/status; do
        [[ -e "$status_file" ]] || continue

        connector="${status_file##*/}"
        connector="${connector%/status}"

        case "$connector" in
            *"$internal_connector")
                continue
                ;;
        esac

        if [[ "$(cat "$status_file")" == "connected" ]]; then
            printf '%s\n' "$connector"
        fi
    done | sort -u
}

snapshot_state() {
    current_state | tr '\n' ' '
}

lid_inhibitor_running() {
    [[ -n "$lid_inhibit_pid" ]] && kill -0 "$lid_inhibit_pid" 2>/dev/null
}

start_lid_inhibitor() {
    if lid_inhibitor_running; then
        return
    fi

    systemd-inhibit         --what=handle-lid-switch:sleep         --mode=block         --who="Hyprland display sync"         --why="External monitor connected"         sleep infinity >/dev/null 2>&1 &
    lid_inhibit_pid=$!
}

stop_lid_inhibitor() {
    if lid_inhibitor_running; then
        kill "$lid_inhibit_pid" 2>/dev/null || true
        wait "$lid_inhibit_pid" 2>/dev/null || true
    fi

    lid_inhibit_pid=""
}

apply_lid_policy() {
    state="$(snapshot_state)"
    if [[ -n "$state" ]]; then
        start_lid_inhibitor
    else
        stop_lid_inhibitor
    fi
}

sync_display_and_keyboard() {
    apply_lid_policy
    lua "$sync_script" # This script handles the keyboard layout and Hyprland reload
    manage_redox_viewer # Manage the redox-layout-viewer
}

# Separate fast polling loop for keyboard detection and viewer management
(
    while true; do
        sleep 0.5
        lua "$sync_script" # Check keyboard and apply layout
        manage_redox_viewer # Manage the redox-layout-viewer
    done
) &


cleanup() {
    stop_lid_inhibitor
    # Also kill redox-layout-viewer if it's running when the script exits
    if pgrep -f "$APP_NAME" > /dev/null; then
        pkill -f "$APP_NAME"
    fi
}

trap cleanup EXIT INT TERM

# Initial run
last_state="$(snapshot_state)"
sync_display_and_keyboard # Initial run for display and keyboard

# Start a lightweight polling fallback that checks connector state every 2s.
# This ensures we catch hotplug changes that might not emit udev events reliably.
(
    while true; do
        sleep 2
        state="$(snapshot_state)"
        if [[ "$state" != "$last_state" ]]; then
            last_state="$state"
            sync_display_and_keyboard
        fi
    done
) &

# If inotifywait is available, also watch the status files for modifications.
if command -v inotifywait >/dev/null 2>&1; then
    (
        inotifywait -m -e modify --format '%w%f' /sys/class/drm/*/status 2>/dev/null |         while IFS= read -r changed; do
            state="$(snapshot_state)"
            if [[ "$state" != "$last_state" ]]; then
                last_state="$state"
                sync_display_and_keyboard
            fi
        done
    ) &
fi

# Also listen to udev events; any drm change can affect lid policy and monitor mode.
while IFS= read -r line; do
    case "$line" in
        UDEV*|KERNEL*)
            now=$(date +%s)
            if (( now - last_sync_ts >= 2 )); then
                last_sync_ts=$now
                last_state="$(snapshot_state)"
                sync_display_and_keyboard
            fi
            ;;
    esac
done < <(udevadm monitor --udev --subsystem-match=drm 2>/dev/null)
