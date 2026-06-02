vim.keymap.set("n", "<leader>bn", ":bnext<CR>")
vim.keymap.set("n", "<leader>bp", ":bprev<CR>")

vim.keymap.set("n", "<leader>bm", ":Telescope buffers<CR>")

vim.keymap.set("n", "<Enter>", "o<Esc>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ'z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--greatest remap ever
vim.keymap.set("x", "<leader>p", '"_dp')

vim.keymap.set({"n","v"}, "<leader>y", '"+y')

vim.keymap.set({"n","v"}, "<leader>d", '"_d')

vim.keymap.set("n", "Q", "<nop>")

--starts a find and replace for the word under the cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Comment all selected lines
vim.keymap.set("v", "<leader>m", function()
    -- Capture visual selection range BEFORE the prompt
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  -- Ensure proper order (visual selection can go bottom-up)
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  vim.ui.input({ prompt = "Comment: " }, function(input)
    if input == nil or input == "" then return end

    -- Escape input for substitution
    local escaped = vim.fn.escape(input, '\\/')

    -- Construct and run the substitute command
    vim.cmd(start_line .. "," .. end_line .. "s/.*/" .. escaped .. "&/")
    vim.cmd("noh");
  end)
end)

--compile commands for C++ projects
vim.keymap.set("n", "<leader>cc",
  ":!cmake --build build/debug<cr>",
  { desc = "Build debug binary" })
vim.keymap.set("n", "<leader>cr",
  ":!cmake --build build/release<cr>",
  { desc = "Build release binary" })
vim.keymap.set("n", "<leader>ci",
  ":!cmake --install build/release<cr>",
  { desc = "Install release binary" })
vim.keymap.set("n", "<leader>con",
  ":!cmake -S . -B build/debug -DCMAKE_BUILD_TYPE=Debug -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=\"$HOME/.local\" && cmake -S . -B build/release -DCMAKE_BUILD_TYPE=Release -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=\"$HOME/.local\"<cr>",
  { desc = "Reconfigure build files" })
