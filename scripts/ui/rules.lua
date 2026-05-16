-- scripts/ui/rules.lua

-- Workspace assignments
hl.window_rule({
    name      = "ws-browsers",
    match     = { class = "^(zen|firefox|firefox-esr|chromium|google-chrome|brave|brave-browser|librewolf|qutebrowser|epiphany|falkon|midori|vivaldi)$" },
    workspace = "1",
})

hl.window_rule({
    name      = "ws-terminals",
    match     = { class = "^(kitty|foot|alacritty|Alacritty|wezterm|org.wezfurlong.wezterm|com.mitchellh.ghostty|URxvt|xterm)$" },
    workspace = "2",
})

hl.window_rule({
    name      = "ws-ides",
    match     = { class = "^(code|code-oss|vscodium|jetbrains-idea|jetbrains-pycharm|jetbrains-webstorm|jetbrains-clion|jetbrains-goland|jetbrains-rider|jetbrains-rustrover|lapce|neovide|zed|Emacs)$" },
    workspace = "3",
})

hl.window_rule({
    name      = "ws-files",
    match     = { class = "^(org.gnome.Nautilus|org.kde.dolphin|org.kde.gwenview|thunar|Thunar|pcmanfm|nemo|doublecmd|krusader)$" },
    workspace = "4",
})

hl.window_rule({
    name      = "ws-onlyoffice",
    match     = { class = "^(onlyoffice-desktopeditors|ONLYOFFICE|DesktopEditors)$" },
    workspace = "5",
})

hl.window_rule({
    name      = "ws-gaming",
    match     = { class = "^(steam|Steam|heroic|com.heroicgameslauncher.hgl|lutris|Lutris|bottles|com.usebottles.bottles|prismlauncher|org.prismlauncher.PrismLauncher|gamescope|net.davidotek.pupgui2)$" },
    workspace = "6",
})

hl.window_rule({
    name         = "goldwarden-autofill",
    match        = { class = "^(com.quexten.goldwarden)$" },
    float        = true,
    size         = "600 400",
    center       = true,
    pin          = true,
    stay_focused = true,
})

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = { class = "^$", title = "^$", xwayland = true, float = true },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name        = "redox-layout",
    match       = { title = "^Redox layout$" },
    float       = true,
    pin         = true,
    border_size = 0,
    rounding    = 0,
    no_shadow   = true,
    no_blur     = true,
    opacity     = 0.8,
    size        = { 500, 300 },
    no_focus    = true,
    move        = { "1400", "800" },
})
