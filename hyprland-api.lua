---@meta

---@alias HL.Direction "left"|"right"|"up"|"down"|"l"|"r"|"u"|"d"
---@alias HL.WorkspaceSelector string|integer
---@alias HL.WindowSelector string|integer

---@class HL.BindOptions
---@field mouse? boolean
---@field locked? boolean
---@field repeating? boolean
---@field dont_inhibit? boolean

---@class HL.MonitorConfig
---@field output string
---@field mode string
---@field position string
---@field scale string|number

---@class HL.ConfigGeneral
---@field gaps_in? number
---@field gaps_out? number
---@field border_size? number
---@field layout? string

---@class HL.ConfigDecorationBlur
---@field enabled? boolean
---@field size? number
---@field passes? number
---@field new_optimizations? boolean
---@field ignore_opacity? boolean

---@class HL.ConfigDecorationShadow
---@field enabled? boolean
---@field range? number
---@field render_power? number
---@field color? number|string

---@class HL.ConfigDecoration
---@field rounding? number
---@field rounding_power? number
---@field active_opacity? number
---@field inactive_opacity? number
---@field shadow? HL.ConfigDecorationShadow
---@field blur? HL.ConfigDecorationBlur

---@class HL.ConfigInputTouchpad
---@field natural_scroll? boolean

---@class HL.ConfigInput
---@field kb_layout? string
---@field kb_variant? string
---@field kb_model? string
---@field kb_options? string
---@field kb_rules? string
---@field follow_mouse? number
---@field sensitivity? number
---@field touchpad? HL.ConfigInputTouchpad

---@class HL.AnimationConfig
---@field leaf string
---@field enabled? boolean
---@field speed? number
---@field bezier? string
---@field style? string

---@class HL.CurveConfig
---@field type string
---@field points { number, number }[]

---@class HL.GestureConfig
---@field fingers number
---@field direction string
---@field action string

---@class HL.DeviceConfig
---@field name string
---@field sensitivity? number

---@class HL.WindowRuleMatch
---@field class? string
---@field title? string
---@field xwayland? boolean
---@field float? boolean
---@field fullscreen? boolean
---@field pin? boolean

---@class HL.WindowRuleConfig
---@field name string
---@field match HL.WindowRuleMatch
---@field float? boolean
---@field size? string
---@field center? boolean
---@field pin? boolean
---@field stay_focused? boolean
---@field suppress_event? string
---@field no_focus? boolean
---@field move? string

---@class HL.FocusDispatcher
---@field direction? HL.Direction
---@field workspace? HL.WorkspaceSelector|string
---@field monitor? string|integer
---@field window? HL.WindowSelector
---@field urgent_or_last? boolean
---@field last? boolean
---@field on_current_monitor? boolean

---@class HL.WindowMoveDispatcher
---@field direction? HL.Direction
---@field workspace? HL.WorkspaceSelector|string
---@field monitor? string|integer
---@field follow? boolean
---@field into_group? HL.Direction|string
---@field into_or_create_group? HL.Direction|string
---@field out_of_group? HL.Direction|string|boolean

---@class HL.WindowFullscreenDispatcher
---@field action? "toggle"|"set"|"unset"
---@field mode? "fullscreen"|"maximized"|0|1

---@class HL.Dispatcher
---@operator call: any

---@class HL.WindowFloatDispatcher
---@field action? "toggle"|"set"|"unset"

---@class HL.DispatchersWindow
---@field close fun(window?: HL.WindowSelector): HL.Dispatcher
---@field kill fun(window?: HL.WindowSelector): HL.Dispatcher
---@field signal fun(opts: { signal: integer, window?: HL.WindowSelector }): HL.Dispatcher
---@field float fun(opts?: HL.WindowFloatDispatcher): HL.Dispatcher
---@field fullscreen fun(opts?: HL.WindowFullscreenDispatcher): HL.Dispatcher
---@field fullscreen_state fun(opts: { internal: integer, client: integer, action?: "toggle"|"set"|"unset", window?: HL.WindowSelector }): HL.Dispatcher
---@field pseudo fun(opts?: { action?: "toggle"|"set"|"unset" }): HL.Dispatcher
---@field move fun(opts: HL.WindowMoveDispatcher): HL.Dispatcher
---@field swap fun(opts: { direction?: HL.Direction, target?: HL.WindowSelector }): HL.Dispatcher
---@field center fun(window?: HL.WindowSelector): HL.Dispatcher
---@field cycle_next fun(opts?: { next?: boolean, tiled?: boolean, floating?: boolean }): HL.Dispatcher
---@field tag fun(opts: { tag: string, window?: HL.WindowSelector }): HL.Dispatcher
---@field clear_tags fun(window?: HL.WindowSelector): HL.Dispatcher
---@field toggle_swallow fun(): HL.Dispatcher
---@field resize fun(opts?: { x?: number, y?: number, relative?: boolean, window?: HL.WindowSelector }): HL.Dispatcher
---@field pin fun(opts?: { action?: "toggle"|"set"|"unset" }): HL.Dispatcher
---@field bring_to_top fun(): HL.Dispatcher
---@field alter_zorder fun(opts: { mode: string, window?: HL.WindowSelector }): HL.Dispatcher
---@field set_prop fun(opts: { prop: string, value: string, window?: HL.WindowSelector }): HL.Dispatcher
---@field deny_from_group fun(opts?: { action?: "toggle"|"set"|"unset" }): HL.Dispatcher
---@field drag fun(): HL.Dispatcher

---@class HL.DispatchersWorkspace
---@field toggle_special fun(name: string): HL.Dispatcher
---@field rename fun(name: string): HL.Dispatcher
---@field move fun(opts: { monitor: string|integer, workspace?: HL.WorkspaceSelector }): HL.Dispatcher
---@field swap_monitors fun(opts: { monitor1: string|integer, monitor2: string|integer }): HL.Dispatcher

---@class HL.DispatchersGroup
---@field toggle fun(): HL.Dispatcher
---@field next fun(): HL.Dispatcher
---@field prev fun(): HL.Dispatcher
---@field active fun(opts: { index: integer, window?: HL.WindowSelector }): HL.Dispatcher
---@field move_window fun(opts?: { forward?: boolean }): HL.Dispatcher
---@field lock fun(opts?: { action?: "toggle"|"lock"|"unlock" }): HL.Dispatcher
---@field lock_active fun(opts?: { action?: "toggle"|"lock"|"unlock" }): HL.Dispatcher

---@class HL.DispatchersCursor
---@field move_to_corner fun(opts?: { corner?: integer, window?: HL.WindowSelector }): HL.Dispatcher
---@field move fun(opts?: { x?: number, y?: number }): HL.Dispatcher

---@class HL.Dispatchers
---@field exec_cmd fun(cmd: string, rules?: table): HL.Dispatcher
---@field exec_raw fun(cmd: string): HL.Dispatcher
---@field exit fun(): HL.Dispatcher
---@field submap fun(name: string): HL.Dispatcher
---@field pass fun(opts: { window: HL.WindowSelector }): HL.Dispatcher
---@field send_shortcut fun(opts: { mods: string, key: string, window?: HL.WindowSelector }): HL.Dispatcher
---@field send_key_state fun(opts: { mods: string, key: string, state: "down"|"up"|"repeat", window?: HL.WindowSelector }): HL.Dispatcher
---@field layout fun(msg: string): HL.Dispatcher
---@field dpms fun(opts: { action?: "toggle"|"on"|"off", monitor?: string|integer }): HL.Dispatcher
---@field event fun(data: string): HL.Dispatcher
---@field global fun(action: string): HL.Dispatcher
---@field force_renderer_reload fun(): HL.Dispatcher
---@field force_idle fun(seconds: number): HL.Dispatcher
---@field focus fun(opts: HL.FocusDispatcher): HL.Dispatcher
---@field no_op fun(): HL.Dispatcher
---@field window HL.DispatchersWindow
---@field workspace HL.DispatchersWorkspace
---@field group HL.DispatchersGroup
---@field cursor HL.DispatchersCursor

---@class HL
---@field on fun(event: string, cb: fun(...): any)
---@field bind fun(keys: string, dispatcher: HL.Dispatcher|fun(...): any, opts?: HL.BindOptions): any
---@field dispatch fun(dispatcher: HL.Dispatcher|fun(...): any): any
---@field env fun(name: string, value: string)
---@field monitor fun(cfg: HL.MonitorConfig)
---@field config fun(cfg: table)
---@field curve fun(name: string, cfg: HL.CurveConfig)
---@field animation fun(cfg: HL.AnimationConfig)
---@field gesture fun(cfg: HL.GestureConfig)
---@field device fun(cfg: HL.DeviceConfig)
---@field window_rule fun(cfg: HL.WindowRuleConfig)
---@field dsp HL.Dispatchers

---@type HL
hl = hl or {}