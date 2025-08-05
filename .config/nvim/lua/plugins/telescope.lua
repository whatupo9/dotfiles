return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require("telescope.builtin")
      local function live_grep_in_dirs()
        builtin.live_grep({
          search_dirs = {
            os.getenv("HOME"),
            "/mnt/shared"
          },
        })
      end

      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', live_grep_in_dirs, {})
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
          }
        },
        pickers = {
          find_files = {
            hidden = true,
          }
        }
      }
      require("telescope").load_extension("ui-select")
    end
  }
}
