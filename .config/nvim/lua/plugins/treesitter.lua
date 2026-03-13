return {
	"nvim-treesitter/nvim-treesitter",
  branch = "master",
	build = ":TSUpdate",
	config = function()
    require("nvim-treesitter.install").prefer_git = true;
		local configs = require("nvim-treesitter.configs")
		configs.setup({
      ensure_installed = {c, cpp, lua, bash, vim, latex},
      auto_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
