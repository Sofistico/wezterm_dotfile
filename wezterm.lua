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

local dimmer = { brightness = 0.4 }
config.background = {
	{
		source = {
			File = wezterm.config_dir .. "/cindy.jpg",
		},
		-- The texture tiles vertically but not horizontally.
		-- When we repeat it, mirror it so that it appears "more seamless".
		-- An alternative to this is to set `width = "100%"` and have
		-- it stretch across the display
		-- repeat_x = 'Mirror',
		hsb = dimmer,
		height = "Contain",
		width = "100%",
	},
}

config.font = wezterm.font_with_fallback({
	{ family = "DejaVuSansM Nerd Font", scale = 0.91 },
	{ family = "Symbols Nerd Font Mono", scale = 0.80 },
})
config.font_size = 10.0
config.hide_tab_bar_if_only_one_tab = false
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
config.quick_select_patterns = {
	"(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$",
	-- Nushell error paths (like ╭─[/path/to/file.nu:1946:63])
	"─\\[(.*\\:\\d+\\:\\d+)\\]",
	-- Table patterns
	-- $env.config.table.mode = "default"
	-- $env.config.table.header_on_separator = true
	-- $env.config.footer_mode = "always"
	"(?<=─|╭|┬)([a-zA-Z0-9 _%.-]+?)(?=─|╮|┬)", -- Headers
	"(?<=│ )([a-zA-Z0-9 _.-]+?)(?= │)", -- Column values

	-- File paths (stops at ~, allows dots in path but stops before dot+space)
	"/[^/\\s│~]+(?:/[^/\\s│~]+)*(?:\\.(?!\\s)[a-zA-Z0-9]+)?",
	-- hopefully this gets the path from .\* and etc
	[[(?:[A-Za-z]:\\|\.\\)?[\w.-]+(?:\\[\w .()-]+)+]],
}

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
	-- {
	-- 	key = "n",
	-- 	mods = "LEADER",
	-- 	action = act.SpawnTab("DefaultDomain"),
	-- },
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
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES|DOMAINS|TABS" }),
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
					if line == "" then
						line = nil
					end
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
	{
		key = "O",
		mods = "CTRL",
		action = wezterm.action({
			QuickSelectArgs = {
				patterns = {
					"https?://\\S+\\b",
				},
				action = wezterm.action_callback(function(window, pane)
					local url = window:get_selection_text_for_pane(pane)
					wezterm.log_info("opening: " .. url)
					wezterm.open_with(url)
				end),
			},
		}),
	},
	-- {
	-- 	key = "U",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = act.PromptInputLine({
	-- 		description = "Enter new workspace name:",
	-- 		action = wezterm.action_callback(function(window, pane, line)
	-- 			if line then
	--          print(window:window_id())
	-- 				window:set_workspace(line)
	-- 			end
	-- 		end),
	-- 	}),
	-- },
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
		socket_path = "~/.local/share/wezterm/sock2",
	},
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

wezterm.on("update-right-status", function(window, _)
	window:set_right_status(window:active_workspace())
end)
-- This is where you actually apply your config choices

-- and finally, return the configuration to wezterm
wezterm.on("update-right-status", function(window, _)
	-- "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M ")

	local bat = ""
	for _, b in ipairs(wezterm.battery_info()) do
		local icon = "🔋 "
		if b.state == 'Charging' then
			icon = icon .. '+ '
		elseif b.state_of_charge < 0.20 then
			icon = '🪫'
		end
		bat = icon .. string.format("%.0f%%", b.state_of_charge * 100)
	end

	window:set_right_status(wezterm.format({
		{ Text = bat .. "   " .. date },
	}))
end)

wezterm.on('bell', function(window, pane)
  wezterm.log_info('the bell was rung in pane ' .. pane:pane_id() .. '!')
end)

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local edge_background = '#0b0022'
    local background = '#1b1032'
    local foreground = '#808080'

    if tab.is_active then
      background = '#2b2042'
      foreground = '#c0c0c0'
    elseif hover then
      background = '#3b3052'
      foreground = '#909090'
    end

    local edge_foreground = background

    local title = tab_title(tab)

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    title = wezterm.truncate_right(title, max_width - 2)

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_LEFT_ARROW },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end
)

wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

return config
