local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.color_scheme = 'Dracula (Official)'
config.font = wezterm.font 'Inconsolata Nerd Font Mono'
config.font_size = 18.0

config.initial_cols = 160
config.initial_rows = 75

local dimmer = { brightness = 0.1 }
config.enable_scroll_bar = true
config.min_scroll_bar_height = '2cell'
config.colors = {
    scrollbar_thumb = 'white',
}

config.scrollback_lines = 50000

config.window_background_opacity = 0.8
config.macos_window_background_blur = 20


config.keys = {
    {
        key = '"',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    {
        key = '%',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
}

-- and finally, return the configuration to wezterm
return config
