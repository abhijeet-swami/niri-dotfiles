return {
	{
		"bjarneo/aether.nvim",
		name = "aether",
		priority = 1000,
		opts = {
			disable_italics = false,
			colors = {
				base00 = "#F8F8F8", -- Forced white background
				base01 = "{{color7  | lighten(0.25)}}", -- Statusbar (very light gray)
				base02 = "{{color7  | lighten(0.15)}}", -- Selection background
				base03 = "{{color8  | darken(0.2) | saturate(0.2)}}", -- Comments (medium gray)
				base04 = "{{foreground | darken(0.4)}}", -- Subtle UI text
				base05 = "{{foreground | darken(0.7)}}", -- Main text (dark)
				base06 = "{{color0  | darken(0.4)}}", -- Light foreground
				base07 = "{{color0  | darken(0.6)}}", -- Darkest shade

				base08 = "{{color1  | darken(0.25) | saturate(0.5)}}", -- Red: errors, variables
				base09 = "{{color3  | darken(0.35) | saturate(0.5)}}", -- Yellow: integers, constants
				base0A = "{{color11 | darken(0.3)  | saturate(0.5)}}", -- Bright yellow: types
				base0B = "{{color2  | darken(0.25) | saturate(0.5)}}", -- Green: strings
				base0C = "{{color6  | darken(0.35) | saturate(0.5)}}", -- Cyan: support, regex
				base0D = "{{color4  | darken(0.25) | saturate(0.5)}}", -- Blue: functions
				base0E = "{{color5  | darken(0.25) | saturate(0.5)}}", -- Magenta: keywords
				base0F = "{{color9  | darken(0.25) | saturate(0.5)}}", -- Bright red: deprecated
			},
		},
		config = function(_, opts)
			require("aether").setup(opts)
			vim.cmd.colorscheme("aether")
			require("aether.hotreload").setup()
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = { colorscheme = "aether" },
	},
}
