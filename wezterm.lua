-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
-- Allow working with both the current release and the nightly
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font_with_fallback({
	{ family = "DejaVuSansM Nerd Font", scale = 0.91 },
	{ family = "Symbols Nerd Font Mono", scale = 0.80 },
})
config.font_size = 10.0
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.colors = { cursor_bg = "#a54cff" }
config.default_prog = { "nu" }
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1001 }
config.color_scheme = "Catppuccin Mocha" -- Mocha, Macchiato, Frappe or Latte

config.keys = {
	{
		key = "v",
		mods = "LEADER|CTRL",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "q",
		mods = "LEADER|CTRL",
		action = act.SendKey({ key = "q", mods = "CTRL" }),
	},
	{
		key = "s",
		mods = "LEADER|CTRL",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "T",
		mods = "LEADER|SHIFT",
		action = act.SpawnTab({ DomainName = "WSL:Ubuntu" }),
	},
	{
		key = "t",
		mods = "LEADER|CTRL",
		action = act.SpawnCommandInNewTab({ label = "Spawn new Powershell", args = { "pwsh" } }),
	},
	{
		key = "d",
		mods = "LEADER",
		action = act.DetachDomain("CurrentPaneDomain"),
	},
	{
		key = "u",
		mods = "LEADER",
		action = act.AttachDomain("unix"),
	},
	{
		key = "t",
		mods = "LEADER",
		action = act.SpawnTab("DefaultDomain"),
	},
	{
		key = "n",
		mods = "LEADER",
		action = act.SpawnTab("DefaultDomain"),
	},
	{
		key = "w",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = false }),
	},
	{ key = "k", mods = "LEADER|CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "LEADER|CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "h", mods = "LEADER|CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER|CTRL", action = act.ActivatePaneDirection("Right") },
	{
		key = "p",
		mods = "LEADER",
		action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }),
	},
	{
		key = "x",
		mods = "LEADER|CTRL",
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES|DOMAINS" }),
	},
	{ key = "n", mods = "LEADER|CTRL", action = act.SwitchWorkspaceRelative(1) },
	{ key = "p", mods = "LEADER|CTRL", action = act.SwitchWorkspaceRelative(-1) },
	-- Create a new workspace with a random name and switch to it
	{ key = "i", mods = "LEADER|CTRL", action = act.SwitchToWorkspace },
	{
		mods = "LEADER",
		key = "m",
		action = act.TogglePaneZoomState,
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		mods = "LEADER",
		key = "0",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		key = "w",
		mods = "LEADER|CTRL",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	{
		key = "!",
		mods = "LEADER | SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local tab, window = pane:move_to_new_tab()
		end),
	},
	{
		key = "!",
		mods = "LEADER | SHIFT | CTRL",
		action = wezterm.action_callback(function(win, pane)
			local tab, window = pane:move_to_new_window()
		end),
	},
}

config.wsl_domains = {
	{
		name = "WSL:Ubuntu",
		distribution = "Ubuntu",
		username = "sofistico",
		default_cwd = "/home/sofistico",
		-- default_prog = { "fish", "-l" },
	},
}

config.unix_domains = {
	{
		-- The name; must be unique amongst all domains
		name = "unix",

		-- The path to the socket.  If unspecified, a reasonable default
		-- value will be computed.

		-- socket_path = "/some/path",

		-- If true, do not attempt to start this server if we try and fail to
		-- connect to it.

		-- no_serve_automatically = false,

		-- If true, bypass checking for secure ownership of the
		-- socket_path.  This is not recommended on a multi-user
		-- system, but is useful for example when running the
		-- server inside a WSL container but with the socket
		-- on the host NTFS volume.

		-- skip_permissions_check = false,
	},
	{
		name = "unix2",
		socket_path = '~/.local/share/wezterm/sock2'
	}
}

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

wezterm.on("gui-attached", function(domain)
	-- maximize all displayed windows on startup
	local workspace = mux.get_active_workspace()
	for _, window in ipairs(mux.all_windows()) do
		if window:get_workspace() == workspace then
			window:gui_window():toggle_fullscreen()
		end
	end
end)

wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)
-- This is where you actually apply your config choices

-- and finally, return the configuration to wezterm
return config
