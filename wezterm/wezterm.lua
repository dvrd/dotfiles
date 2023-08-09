local wezterm = require("wezterm")
-- local mux = wezterm.mux
-- local act = wezterm.action

local config = {
	font = wezterm.font("Liga SFMono Nerd Font", {
		weight = "DemiBold",
	}),
	font_size = 14,
	line_height = 1.2,
	color_scheme = "carbonfox",
	window_decorations = "RESIZE",
	hide_tab_bar_if_only_one_tab = true,
	-- window_background_opacity = 0.75,
	inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.7,
	},
	scrollback_lines = 3500,
	enable_scroll_bar = true,
	debug_key_events = true,
	adjust_window_size_when_changing_font_size = false,
	use_fancy_tab_bar = false,
	tab_max_width = 600,
}

return config
