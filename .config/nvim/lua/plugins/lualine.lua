return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local ayu = require("lualine.themes.ayu_dark")
		for _, mode in pairs(ayu) do
			if mode.c then
				mode.c.bg = "none"
			end
			if mode.b then
				mode.b.bg = "none"
			end
		end

		require("lualine").setup({
			options = {
				theme = ayu,
			},
		})
	end,
}
