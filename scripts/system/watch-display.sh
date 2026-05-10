#!/usr/bin/env bash
set -eu

home="${HOME:-/home/breadway}"
sync_script="$home/.config/hypr/scripts/system/sync-display.lua"
preview_cmd="$home/redox-layout-viewer/target/release/redox-layout-viewer"
preview_app_name="redox-layout-vi"
preview_usb_id="4d44:5244"
internal_connector="eDP-1"
lid_inhibit_pid=""
last_sync_ts=0
last_keyboard_state=""

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
            printf '%s
' "$connector"
        fi
    done | sort -u
}

snapshot_state() {
    current_state | tr '
' ' '
}

keyboard_present() {
    lsusb -d "$preview_usb_id" >/dev/null 2>&1
}

keyboard_state() {
    if keyboard_present; then
        echo "connected"
    else
        echo "disconnected"
    fi
}

preview_running() {
    pgrep -f "$preview_app_name" >/dev/null 2>&1
}

sync_keyboard_preview() {
    if keyboard_present; then
        if ! preview_running; then
            "$preview_cmd" >/dev/null 2>&1 &
        fi
    else
        if preview_running; then
            pkill -f "$preview_app_name"
        fi
    fi
}

run_sync() {
    lua "$sync_script"
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

sync_and_policy() {
    apply_lid_policy
    run_sync
}

sync_keyboard() {
    local current_state
    current_state="$(keyboard_state)"
    
    if [[ "$current_state" != "$last_keyboard_state" ]]; then
        last_keyboard_state="$current_state"
        run_sync
    fi
    
    sync_keyboard_preview
}

cleanup() {
    stop_lid_inhibitor
}

trap cleanup EXIT INT TERM

last_state="$(snapshot_state)"
last_keyboard_state="$(keyboard_state)"
sync_and_policy
sync_keyboard

# Start a lightweight polling fallback that checks connector state every 2s.
# This ensures we catch hotplug changes that might not emit udev events reliably.
(
    while true; do
        sleep 2
        state="$(snapshot_state)"
        if [[ "$state" != "$last_state" ]]; then
            last_state="$state"
            sync_and_policy
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
                sync_and_policy
            fi
        done
    ) &
fi

# Keep the Redox layout viewer in sync with USB presence.
(
    while true; do
        sync_keyboard
        sleep 0.5
    done
) &

# Also listen to udev events; any drm change can affect lid policy and monitor mode.
while IFS= read -r line; do
    case "$line" in
        UDEV*|KERNEL*)
            now=$(date +%s)
            if (( now - last_sync_ts >= 2 )); then
                last_sync_ts=$now
                last_state="$(snapshot_state)"
                sync_and_policy
            fi
            ;;
    esac
done < <(udevadm monitor --udev --subsystem-match=drm 2>/dev/null)
