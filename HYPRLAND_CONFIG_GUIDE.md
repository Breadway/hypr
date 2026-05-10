# Hyprland Config Guide

This document explains how this Hyprland configuration is assembled, how the Lua modules interact, and where to make changes safely.

## 1. What loads first

The entire config starts with [hyprland.lua](hyprland.lua), which is just a loader:

```lua
dofile("/home/breadway/.config/hypr/scripts/init.lua")
```

That file does not contain policy or settings. Its only job is to hand control to the modular Lua entrypoint in [scripts/init.lua](scripts/init.lua).

## 2. Main execution flow

The runtime flow is:

1. Hyprland reads [hyprland.lua](hyprland.lua).
2. [scripts/init.lua](scripts/init.lua) resolves `HOME` and builds the config paths.
3. It loads bind data from [binds.json](binds.json) through [scripts/input/binds.lua](scripts/input/binds.lua).
4. It registers all keybinds with [scripts/input/keybinds.lua](scripts/input/keybinds.lua).
5. It loads the rest of the config modules one by one with `dofile(...)`.

The important idea is that this config is data-driven. Most behavior is defined in tables and JSON, not as hardcoded one-off shell commands.

## 3. Why it is structured this way

This layout is meant to avoid a giant single file that becomes hard to reason about.

Benefits:

- Each concern has a dedicated file.
- Paths are `HOME`-aware, so the config is easier to move between machines.
- Binds can be edited in JSON without touching Lua logic.
- The bind system can normalize defaults and validate action types in one place.
- The startup modules can be loaded in a predictable sequence.

## 4. Module map

### [scripts/init.lua](scripts/init.lua)

This is the orchestrator.

Responsibilities:

- Resolve `HOME`.
- Build `config_dir` and `script_dir`.
- Load [binds.json](binds.json).
- Pass bind data into the dispatcher in [scripts/input/keybinds.lua](scripts/input/keybinds.lua).
- Load the remaining modules in order.

Current module order:

1. `display/monitors.lua`
2. `system/autostart.lua`
3. `system/env.lua`
4. `ui/settings.lua`
5. `ui/curves.lua`
6. `ui/animations.lua`
7. `ui/gestures.lua`
8. `ui/devices.lua`
9. `ui/rules.lua`

### [scripts/display/monitors.lua](scripts/display/monitors.lua)

Defines output layout.

Current behavior:

- `eDP-1` is the primary laptop panel.
- The internal panel mode is selected at load time based on whether an external connector is present.
- `DP-3` mirrors `eDP-1`.
- Each monitor gets explicit mode, position, and scale.

This is the right file for display topology changes, docked/undocked profiles, or resolution adjustments.

### [scripts/system/sync-display.lua](scripts/system/sync-display.lua)

Synchronizes the active keybind layout based on keyboard presence when the session starts or when the helper is run manually.

Current behavior:

- Detects the Redox keyboard via USB ID `4d44:5244` using `lsusb`.
- Sets `active_layout` to `colemak` when the keyboard is connected.
- Sets `active_layout` to `qwerty` when the keyboard is disconnected.
- Reloads Hyprland after writing the new layout selection to `binds.json`.

This script is the runtime bridge between keyboard presence and bind layout selection. The watcher invokes it whenever the keyboard's connection state changes.

### [scripts/system/autostart.lua](scripts/system/autostart.lua)

Runs startup commands when Hyprland starts.

Mechanics:

- Commands are stored in a table.
- `hl.on("hyprland.start", ...)` runs them.
- Each command is executed with `hl.exec_cmd(...)`.
- The startup list launches the combined `scripts/system/watch-display.sh` watcher for monitor sync, lid policy, and the Redox keyboard preview.

This module should stay focused on startup side effects only. If something is a persistent environment variable, put it in `env.lua`. If it is a rule or setting, put it elsewhere.

### [scripts/system/env.lua](scripts/system/env.lua)

Sets environment variables for the session.

Current examples:

- `XCURSOR_SIZE`
- `HYPRCURSOR_SIZE`
- `WALLPAPERS`
- `HYPERSHOT_DIR`

This module is where shared session paths and Wayland environment values belong.

### [scripts/ui/settings.lua](scripts/ui/settings.lua)

Defines the core visual and input settings for Hyprland.

It currently covers:

- `general` layout behavior like gaps, border size, and layout choice.
- `decoration` settings like rounding, opacity, shadows, and blur.
- `animations` global enable/disable.
- `master` layout defaults.
- `misc` toggles.
- `input` defaults like keyboard layout, pointer follow behavior, and touchpad scrolling.

If you want the overall feel of the desktop to change, this is one of the main files to edit.

### [scripts/ui/curves.lua](scripts/ui/curves.lua)

Registers named bezier curves.

These curve names are later referenced by animations:

- `easeOutQuint`
- `easeInOutCubic`
- `almostLinear`
- `quick`

Keep curve names stable if other modules depend on them.

### [scripts/ui/animations.lua](scripts/ui/animations.lua)

Defines animation presets.

Each animation entry includes fields like:

- `leaf`
- `enabled`
- `speed`
- `bezier`
- `style`

The file registers each entry with `hl.animation(...)`.

The important detail is that animation curves are decoupled from the animation list. `curves.lua` declares the named curves, and `animations.lua` consumes those names.

### [scripts/ui/gestures.lua](scripts/ui/gestures.lua)

Defines touchpad or gesture behavior.

Current behavior maps a 3-finger horizontal swipe to workspace switching.

This module is intentionally tiny, which is good: gestures tend to be simple and should stay obvious.

### [scripts/ui/devices.lua](scripts/ui/devices.lua)

Registers device-specific settings.

Current behavior sets mouse sensitivity for `epic-mouse-v1`.

Use this file for hardware-specific tuning that should not affect every input device.

### [scripts/ui/rules.lua](scripts/ui/rules.lua)

Defines window rules.

Current rules handle things like:

- Floating and pinning specific apps.
- Suppressing maximize events globally.
- Fixing XWayland drag behavior.
- Moving certain helper windows to a preferred area.

This is the place for class/title-based behavior, automatic floating, centering, pinning, size constraints, and special handling for broken apps.

## 5. Bind system

The bind system is split into three parts:

- [binds.json](binds.json) is the data file.
- [scripts/input/binds.lua](scripts/input/binds.lua) loads and normalizes the data.
- [scripts/input/keybinds.lua](scripts/input/keybinds.lua) converts the data into Hyprland dispatchers.

### [binds.json](binds.json)

This is the source of truth for keybind definitions.

Schema shape:

```json
{
  "active_layout": "qwerty",
  "default_mods": ["SUPER"],
  "globals": [
    {
      "key": "XF86AudioMute",
      "action": "exec",
      "mods": []
    }
  ],
  "layouts": {
    "qwerty": [
      {
        "key": "RETURN",
        "action": "exec",
        "command": "kitty"
      }
    ],
    "colemak": [
      {
        "key": "RETURN",
        "action": "exec",
        "command": "kitty"
      }
    ]
  }
}
```

Core ideas:

- `active_layout` selects which explicit layout array is active (`qwerty` or `colemak`).
- `default_mods` defines the modifier set used when a bind omits `mods`.
- `layouts.<name>` stores layout-specific binds.
- `globals` stores binds shared by every layout.
- `mods: []` is meaningful and means "no modifiers".
- `options` is passed through to `hl.bind(...)`.

Supported actions in this config:

- `exec`
- `kill`
- `exit`
- `float`
- `fullscreen`
- `layout`
- `focus`
- `move`
- `drag`
- `resize`

### How modifiers work

The modifier logic is intentionally defensive.

If `mods` is omitted:

- the bind inherits `default_mods`.

If `mods` is an empty array:

- the bind gets no modifiers at all.

If `mods` is a string or a list containing strings with `+` separators:

- it is normalized into a clean array of modifier names.

This means the config can tolerate both human-edited and tool-generated input without breaking the dispatcher.

Layout selection details:

- `active_layout: "qwerty"` activates `layouts.qwerty`.
- `active_layout: "colemak"` activates `layouts.colemak`.
- No positional key conversion is performed. Layout arrays are edited explicitly.
- You can override layout at runtime with the `HYPR_BIND_LAYOUT` environment variable when `active_layout` is not set.
- In the current workflow, `scripts/system/sync-display.lua` writes `active_layout` directly before reloading Hyprland, so the JSON file remains the source of truth for the active layout.

### [scripts/input/binds.lua](scripts/input/binds.lua)

Loads the JSON file and normalizes the top-level schema.

It also enforces a safe fallback:

- If the JSON cannot be loaded, `default_mods` falls back to `SUPER`.
- `bindings` falls back to an empty array for legacy configs.

This file is intentionally small. It should only validate shape and normalize defaults, not implement bind behavior.

### [scripts/input/keybinds.lua](scripts/input/keybinds.lua)

Turns bind definitions into native Hyprland dispatchers.

Important behavior:

- It uses `hl.dsp.*` dispatchers directly.
- It does not shell out through a custom `hyprctl dispatch` wrapper.
- Each action type is mapped through an `action_builders` table.
- The final string passed to `hl.bind(...)` is built from the normalized modifiers and key.

Dispatcher mapping:

- `exec` -> `hl.dsp.exec_cmd(entry.command)`
- `kill` -> `hl.dsp.window.kill()`
- `exit` -> `hl.dsp.exit()`
- `float` -> `hl.dsp.window.float({ action = "toggle" })`
- `fullscreen` -> `hl.dsp.window.fullscreen({ action = "toggle" })`
- `layout` -> `hl.dsp.layout(entry.layout)`
- `focus` -> `hl.dsp.focus({ direction = entry.direction, workspace = entry.workspace })`
- `move` -> `hl.dsp.window.move({ workspace = entry.workspace })`
- `drag` -> `hl.dsp.window.drag()`
- `resize` -> `hl.dsp.window.resize()`

This is the module to inspect if a bind exists in JSON but does not fire as expected.

## 6. Default modifiers and enforcement

`default_mods` are enforced in two layers:

1. The JSON loader keeps the config schema sane.
2. The bind dispatcher applies the default modifier list when a bind does not explicitly define `mods`.

That means the default modifier rule is not just a convention. It is part of the wiring.

Practical result:

- Most binds inherit `SUPER` automatically.
- Special binds can override that by providing their own `mods`.
- Media keys or other global shortcuts can intentionally use `mods: []`.

## 7. Adding a new bind

The preferred workflow is to use the interactive helper or edit [binds.json](binds.json) carefully.

### Option A: use the CLI helper

Run the helper script:

```bash
/home/breadway/.local/bin/hyprbind
```

It provides:

- Menu navigation.
- Bind preview.
- Modifier presets.
- Conflict detection.
- A key reference.
- Colored output for readability.

### Option B: edit JSON directly

Add a new object to `bindings`.

Example:

```json
{
  "key": "R",
  "action": "resize"
}
```

Because `mods` is omitted here, the bind inherits `default_mods`.

If you want a mouse-driven resize bind that is not the default modifier set, define it explicitly:

```json
{
  "key": "mouse:273",
  "mods": ["SUPER", "SHIFT"],
  "action": "resize",
  "options": { "mouse": true }
}
```

## 8. Common patterns in this config

### Window management

Use `ui/rules.lua` for automatic behavior tied to app identity.
Use `input/keybinds.lua` plus `binds.json` for user-triggered actions.

### Startup behavior

Use `system/autostart.lua` when something should run once on session startup.

### Shared paths

Use `system/env.lua` when multiple modules or apps need the same filesystem path.

### Session look and feel

Use `ui/settings.lua`, `ui/curves.lua`, and `ui/animations.lua` together.

### Hardware tuning

Use `ui/devices.lua` for device-specific pointer behavior.
Use `display/monitors.lua` for output layout.

## 9. How to change things safely

Recommended order of checks when editing this config:

1. Decide which module owns the behavior.
2. Keep the change as local as possible.
3. Prefer table-driven data over repeated imperative calls.
4. Keep `HOME`-aware paths instead of hardcoding a user directory.
5. Validate Lua syntax after edits.
6. Reload Hyprland and test the exact feature you changed.

## 10. Design rules for future edits

If you are extending this config, keep these principles intact:

- Use native Hyprland Lua dispatchers instead of shell wrappers.
- Keep startup and runtime concerns separated.
- Keep JSON as data, not logic.
- Keep the bind dispatcher generic.
- Prefer small modules with single responsibilities.
- Preserve the default-modifier behavior unless you are intentionally creating a special-case bind.
- When a runtime helper needs to switch layouts, update `binds.json` and reload Hyprland rather than trying to infer the bind layout from monitor state in multiple places.

## 11. Quick file reference

- [hyprland.lua](hyprland.lua) - top-level loader.
- [scripts/init.lua](scripts/init.lua) - orchestrator.
- [scripts/input/binds.lua](scripts/input/binds.lua) - JSON loading and normalization.
- [scripts/input/keybinds.lua](scripts/input/keybinds.lua) - bind dispatch registration.
- [binds.json](binds.json) - bind data.
- [scripts/system/autostart.lua](scripts/system/autostart.lua) - startup commands.
- [scripts/system/env.lua](scripts/system/env.lua) - environment variables.
- [scripts/system/watch-display.sh](scripts/system/watch-display.sh) - combined display, lid, and keyboard watcher.
- [scripts/system/sync-display.lua](scripts/system/sync-display.lua) - runtime display and bind-layout sync.
- [scripts/display/monitors.lua](scripts/display/monitors.lua) - outputs and monitor layout.
- [scripts/ui/settings.lua](scripts/ui/settings.lua) - core Hyprland settings.
- [scripts/ui/curves.lua](scripts/ui/curves.lua) - named bezier curves.
- [scripts/ui/animations.lua](scripts/ui/animations.lua) - animation presets.
- [scripts/ui/gestures.lua](scripts/ui/gestures.lua) - gesture bindings.
- [scripts/ui/devices.lua](scripts/ui/devices.lua) - device-specific tuning.
- [scripts/ui/rules.lua](scripts/ui/rules.lua) - window rules.
- [scripts/add-bind.lua](scripts/add-bind.lua) - interactive bind editor.

## 12. Bottom line

This config is built around a simple idea: keep Hyprland behavior in small Lua modules, keep binds in JSON, and keep runtime wiring in a single orchestrator. That makes the setup easier to extend, easier to audit, and easier for future humans or agents to modify without breaking unrelated parts.
