--To ignore case when writing file, in CASE, ha get it? shift if held too long
vim.api.nvim_create_user_command("W", function()
    vim.cmd("w")
end, {})

--Sets current directory to config folder
vim.api.nvim_create_user_command("Config", function()
    vim.cmd("cd C:\\Users\\camer\\AppData\\Local\\nvim")
end, {})

--Sets current directory to config folder
vim.api.nvim_create_user_command("Proj", function()
    vim.cmd("cd C:\\Users\\camer\\Neovim\\projects")
end, {})

--Sets the curret open file to the source file for cmake
vim.api.nvim_create_user_command("SetSource", function()
    -- Get the currently open file's relative path
    local file = vim.fn.expand("%:p"):gsub("\\", "/") -- Absolute path of current file
    local cwd = vim.fn.getcwd()                    -- Get current working directory

    -- Find CMakeLists.txt in the project root
    local project_root = cwd
    while project_root ~= "/" do
        if vim.fn.filereadable(project_root .. "/CMakeLists.txt") == 1 then
            break
        end
        project_root = vim.fn.fnamemodify(project_root, ":h") -- Move up a directory
    end

    local cmake_path = project_root .. "/CMakeLists.txt"

    -- Read CMakeLists.txt into a table
    local cmake_lines = {}
    local file_handle = io.open(cmake_path, "r")
    if not file_handle then
        vim.notify("Error: Could not open CMakeLists.txt.", vim.log.levels.ERROR)
        return
    end

    for line in file_handle:lines() do
        table.insert(cmake_lines, line)
    end
    file_handle:close()

    -- Ensure line 55 exists
    if #cmake_lines < 55 then
        vim.notify("Error: CMakeLists.txt has fewer than 56 lines.", vim.log.levels.ERROR)
        return
    end

    -- Replace line 55 with the new source file path
    cmake_lines[55] = file

    -- Write back the updated CMakeLists.txt
    file_handle = io.open(cmake_path, "w")
    if not file_handle then
        vim.notify("Error: Could not write to CMakeLists.txt.", vim.log.levels.ERROR)
        return
    end

    for _, line in ipairs(cmake_lines) do
        file_handle:write(line .. "\n")
    end
    file_handle:close()
end, {})

function transBg()
    local highlight_groups = {
        "Normal",
        "NormalNC",
        "StatusLine",
        "StatusLineNC",
        "VertSplit",
        "Folded",
        "FoldColumn",
        "Comment",
        "Pmenu",
        "PmenuSel",
        "PmenuSbar",
        "PmenuThumb",
        "IncSearch",
        "MatchParen",
        "WarningMsg",
        "ErrorMsg",
        "MoreMsg",
        "ModeMsg",
        "Question",
        "WildMenu",
        "Terminal",
        "StatusLineTerm",
        "StatusLineNC",
        "EndOfBuffer",
        "LineNr",
        "CursorLineNr",
        "NoiceCmdlinePopup",
        "SignColumn",
    }

    for _, group in ipairs(highlight_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" }) -- Set all backgrounds to transparent
    end
end

-- Automatically save folds
vim.api.nvim_create_autocmd("BufWinLeave", {
    pattern = "*",
    callback = function()
        if vim.fn.bufname() ~= "" then
            vim.cmd("mkview")
        end
    end,
})

-- Automatically recover folds
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    callback = function()
        if vim.fn.bufname() ~= "" then
            vim.cmd("silent! loadview")
        end
    end,
})
