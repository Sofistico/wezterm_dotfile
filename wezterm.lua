-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
local config = {
	font = wezterm.font_with_fallback({
		{ family = "DejaVuSansM Nerd Font Mono", scale = 0.90 },
		{ family = "Symbols Nerd Font Mono", scale = 0.80 },
	}),
	font_size = 10.0,
	hide_tab_bar_if_only_one_tab = true,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	colors = {
		cursor_bg = "#a54cff",
		cursor_fg = "#7f00ff",
	},
	default_prog = { "pwsh" },
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{
			key = "|",
			mods = "LEADER|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "LEADER",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "t",
			mods = "LEADER|SHIFT",
			action = act.SpawnTab({ DomainName = "WSL:Ubuntu" }),
		},
		{
			key = "d",
			mods = "LEADER",
			action = act.DetachDomain("CurrentPaneDomain"),
		},
		{
			key = "u",
			mods = "LEADER",
			action = act.AttachDomain("WSL:Ubuntu"),
		},
		{
			key = "t",
			mods = "LEADER",
			action = act.SpawnTab("DefaultDomain"),
		},
		{
			key = "w",
			mods = "LEADER",
			action = act.CloseCurrentPane({ confirm = true }),
		},
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
		{
			key = "p",
			mods = "LEADER",
			action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }),
		},
	},
	wsl_domains = {
		{
			name = "WSL:Ubuntu",
			distribution = "Ubuntu",
			username = "sofistico",
			default_cwd = "/home/sofistico",
			-- default_prog = { "fish", "-l" },
		},
	},
}

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

-- This is where you actually apply your config choices

-- and finally, return the configuration to wezterm
return config

