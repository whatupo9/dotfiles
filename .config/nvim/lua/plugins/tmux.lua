return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1

    vim.keymap.set("n", "<M-h>", "<cmd>TmuxNavigateLeft<cr>")
    vim.keymap.set("n", "<M-j>", "<cmd>TmuxNavigateDown<cr>")
    vim.keymap.set("n", "<M-k>", "<cmd>TmuxNavigateUp<cr>")
    vim.keymap.set("n", "<M-l>", "<cmd>TmuxNavigateRight<cr>")
  end,
}
