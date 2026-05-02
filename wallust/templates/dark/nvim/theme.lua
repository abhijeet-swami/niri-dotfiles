return {
	{
		"bjarneo/aether.nvim",
		name = "aether",
		priority = 1000,
		opts = {
			disable_italics = false,
			colors = {
				base00 = "{{background}}", -- Default background
				base01 = "{{color0}}", -- Statusbar / lighter bg
				base02 = "{{color8}}", -- Selection background
				base03 = "{{color8}}", -- Comments / invisibles
				base04 = "{{color7}}", -- Subtle UI text
				base05 = "{{foreground}}", -- Main text
				base06 = "{{color7}}", -- Light foreground
				base07 = "{{color15}}", -- Brightest / borders

				base08 = "{{color1}}", -- Red: variables, errors
				base09 = "{{color3}}", -- Yellow: integers, constants
				base0A = "{{color11}}", -- Bright yellow: types, classes
				base0B = "{{color2}}", -- Green: strings
				base0C = "{{color6}}", -- Cyan: support, regex
				base0D = "{{color4}}", -- Blue: functions, keywords
				base0E = "{{color5}}", -- Magenta: keywords, storage
				base0F = "{{color9}}", -- Bright red: deprecated
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
