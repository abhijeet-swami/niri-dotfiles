return {
	{
		"bjarneo/aether.nvim",
		name = "aether",
		priority = 1000,
		opts = {
			disable_italics = false,
			colors = {
				base00 = "#050804", -- Default background
				base01 = "#524C2F", -- Statusbar / lighter bg
				base02 = "#5A5C58", -- Selection background
				base03 = "#5A5C58", -- Comments / invisibles
				base04 = "#80847E", -- Subtle UI text
				base05 = "#ACAFAA", -- Main text
				base06 = "#80847E", -- Light foreground
				base07 = "#80847E", -- Brightest / borders

				base08 = "#484E44", -- Red: variables, errors
				base09 = "#6B8A05", -- Yellow: integers, constants
				base0A = "#6B8A05", -- Bright yellow: types, classes
				base0B = "#787A78", -- Green: strings
				base0C = "#FFEC00", -- Cyan: support, regex
				base0D = "#F49641", -- Blue: functions, keywords
				base0E = "#BBBDA5", -- Magenta: keywords, storage
				base0F = "#484E44", -- Bright red: deprecated
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
