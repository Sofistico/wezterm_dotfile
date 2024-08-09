-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This will hold the configuration.
local config = {
	font = wezterm.font_with_fallback({
	{ family = 'DejaVuSansM Nerd Font Mono', scale = 0.90 },
	{ family = "Symbols Nerd Font Mono", scale = 0.80} }),
	hide_tab_bar_if_only_one_tab = true,
	window_padding = {
	  left = 0,
	  right = 0,
	  top = 0,
	  bottom = 0,
	},
	colors = {
	  cursor_bg = '#a54cff',
	  cursor_fg = '#7f00ff',
	},
	keys = {
		{
			key = 'F3',
			action = wezterm.action.ToggleFullScreen,
		},
	},
	--default_prog = { "C:/cygwin64/Cygwin" }
	default_prog = { "pwsh" }
}

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

-- This is where you actually apply your config choices

-- and finally, return the configuration to wezterm
return config