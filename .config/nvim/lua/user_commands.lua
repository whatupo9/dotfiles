--To ignore case when writing file, in CASE, ha get it? shift if held too long
vim.api.nvim_create_user_command("W", function()
    vim.cmd("w")
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
