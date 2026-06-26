local M = {}

local terminals = {}
local current_label = nil

local function open_term_on_right(bufnr)
    vim.cmd("botright vs")
    if bufnr then
        vim.api.nvim_win_set_buf(0, bufnr)
    else
        vim.cmd("term")
    end
end

--- Focus the terminal window for a given bufnr, opening a split if needed,
--- then send text and enter Insert mode.
local function focus_and_send(bufnr, text)
    local win_found = false
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
            vim.api.nvim_set_current_win(win)
            win_found = true
            break
        end
    end

    if not win_found then
        open_term_on_right(bufnr)
    end

    local chan = vim.bo[bufnr].channel
    if chan and chan ~= 0 then
        vim.api.nvim_chan_send(chan, text)
        vim.cmd("startinsert")
    else
        vim.notify("Rookie AI: Terminal channel not found", vim.log.levels.ERROR)
    end
end

local function validate_terminal(label)
    local bufnr = terminals[label]
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return nil
    end
    return bufnr
end

function M.toggle_term(opts)
    local label = opts.args
    if not label or label == "" or not label:match("^[abcd]$") then
        vim.notify(
            "Rookie AI: Label must be one of: a, b, c, d",
            vim.log.levels.WARN
        )
        return
    end

    local bufnr = validate_terminal(label)
    if bufnr then
        -- Terminal exists, find or re-open its window
        local win_found = false
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_buf(win) == bufnr then
                vim.api.nvim_set_current_win(win)
                win_found = true
                break
            end
        end

        if not win_found then
            open_term_on_right(bufnr)
        end
    else
        -- Create a new terminal
        open_term_on_right()
        terminals[label] = vim.api.nvim_get_current_buf()
    end

    current_label = label
end

function M.add_file()
    -- 1. Get relative path
    local rel_path = vim.fn.expand("%:.")
    if rel_path == "" then
        vim.notify("Rookie AI: Buffer has no name", vim.log.levels.WARN)
        return
    end

    -- 2. Check a terminal has been selected
    if not current_label then
        vim.notify(
            "Rookie AI: No terminal selected. Toggle one with <leader>tm{a,s,d,f} first.",
            vim.log.levels.WARN
        )
        return
    end

    -- 3. Validate the terminal buffer
    local bufnr = validate_terminal(current_label)
    if not bufnr then
        vim.notify(
            "Rookie AI: Terminal '" .. current_label .. "' is closed. Please toggle it again.",
            vim.log.levels.WARN
        )
        return
    end

    -- 4. Compose and send
    local quote = string.format("@%s ", rel_path)
    focus_and_send(bufnr, quote)
end

function M.add_lines(opts)
    -- 1. Save current buffer if modified
    if vim.bo.modified then
        vim.cmd("silent! write")
    end

    -- 2. Get relative path
    local rel_path = vim.fn.expand("%:.")
    if rel_path == "" then
        vim.notify("Rookie AI: Buffer has no name", vim.log.levels.WARN)
        return
    end

    -- 3. Check a terminal has been selected
    if not current_label then
        vim.notify(
            "Rookie AI: No terminal selected. Toggle one with <leader>tm{a,b,c,d} first.",
            vim.log.levels.WARN
        )
        return
    end

    -- 4. Validate the terminal buffer
    local bufnr = validate_terminal(current_label)
    if not bufnr then
        vim.notify(
            "Rookie AI: Terminal '" .. current_label .. "' is closed. Please toggle it again.",
            vim.log.levels.WARN
        )
        return
    end

    -- 5. Get line range
    local line_start = opts.line1
    local line_end = opts.line2

    -- 6. Compose format
    local range_str
    if line_start == line_end then
        range_str = string.format(":%d", line_start)
    else
        range_str = string.format(":%d-%d", line_start, line_end)
    end
    local quote = string.format("@%s %s ", rel_path, range_str)

    focus_and_send(bufnr, quote)
end

function M.setup()
    local labels = { "a", "b", "c", "d" }

    for _, label in ipairs(labels) do
        vim.api.nvim_create_user_command(
            "RkAiTermToggle" .. label:upper(),
            function(opts)
                -- Re-package args to match the old command interface
                M.toggle_term({ args = label })
            end,
            { desc = "Toggle Rookie AI Terminal '" .. label .. "'" }
        )
    end

    vim.api.nvim_create_user_command("RkAiAddFile", function()
        M.add_file()
    end, { desc = "Add current file relative path to AI terminal" })

    vim.api.nvim_create_user_command("RkAiAddLines", function(opts)
        M.add_lines(opts)
    end, { range = true, desc = "Add selected lines to AI terminal" })
end

return M
