return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.cppcheck.with({
          extra_args = { "--language=c++", "--force" },
        }),
        null_ls.builtins.formatting.clang_format.with({
          extra_args = { "--style=file" },
        }),
      },
    })
  end,
}
