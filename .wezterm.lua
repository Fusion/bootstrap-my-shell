local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Mocha'
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
config.background = {
    -- This is the deepest/back-most layer. It will be rendered first
    {
        source = {
            File = '/Users/chris/.wezterm/Alien_Ship/Backgrounds/spaceship_bg_1.png',
        },
        -- The texture tiles vertically but not horizontally.
        -- When we repeat it, mirror it so that it appears "more seamless".
        -- An alternative to this is to set `width = "100%"` and have
        -- it stretch across the display
        repeat_x = 'Mirror',
        hsb = dimmer,
        -- When the viewport scrolls, move this layer 10% of the number of
        -- pixels moved by the main viewport. This makes it appear to be
        -- further behind the text.
        attachment = { Parallax = 0.1 },
    },
    -- Subsequent layers are rendered over the top of each other
    {
        source = {
            File = '/Users/chris/.wezterm/Alien_Ship/Overlays/overlay_1_spines.png',
        },
        width = '100%',
        repeat_x = 'NoRepeat',

        -- position the spins starting at the bottom, and repeating every
        -- two screens.
        vertical_align = 'Bottom',
        repeat_y_size = '200%',
        hsb = dimmer,

        -- The parallax factor is higher than the background layer, so this
        -- one will appear to be closer when we scroll
        attachment = { Parallax = 0.2 },
    },
    {
        source = {
            File = '/Users/chris/.wezterm/Alien_Ship/Overlays/overlay_2_alienball.png',
        },
        width = '100%',
        repeat_x = 'NoRepeat',

        -- start at 10% of the screen and repeat every 2 screens
        vertical_offset = '10%',
        repeat_y_size = '200%',
        hsb = dimmer,
        attachment = { Parallax = 0.3 },
    },
    {
        source = {
            File = '/Users/chris/.wezterm/Alien_Ship/Overlays/overlay_3_lobster.png',
        },
        width = '100%',
        repeat_x = 'NoRepeat',

        vertical_offset = '30%',
        repeat_y_size = '200%',
        hsb = dimmer,
        attachment = { Parallax = 0.4 },
    },
    {
        source = {
            File = '/Users/chris/.wezterm/Alien_Ship/Overlays/overlay_4_spiderlegs.png',
        },
        width = '100%',
        repeat_x = 'NoRepeat',

        vertical_offset = '50%',
        repeat_y_size = '150%',
        hsb = dimmer,
        attachment = { Parallax = 0.5 },
    },
}

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
