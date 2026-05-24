local M = {}

local term_bufnr = nil

function M.toggle_term()
  if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
    -- Terminal exists, find if it's open in any window
    local win_found = false
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) == term_bufnr then
        vim.api.nvim_set_current_win(win)
        win_found = true
        break
      end
    end

    -- If the buffer exists but isn't visible in the current tabpage,
    -- open a vertical split and attach the buffer.
    if not win_found then
      vim.cmd("vs")
      vim.api.nvim_win_set_buf(0, term_bufnr)
    end
  else
    -- Terminal does not exist, create a new one
    vim.cmd("vs | term")
    term_bufnr = vim.api.nvim_get_current_buf()
  end
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

  -- 3. Get visual selected line ranges
  local line_start = opts.line1
  local line_end = opts.line2

  -- 4. Compose format
  local quote = string.format("@%s :%d-%d ", rel_path, line_start, line_end)

  -- 5. Paste to existing terminal
  if not term_bufnr or not vim.api.nvim_buf_is_valid(term_bufnr) then
    vim.notify("Rookie AI: No active terminal. Please run RkAiTermToggle first.", vim.log.levels.WARN)
    return
  end

  local chan = vim.bo[term_bufnr].channel
  if chan and chan ~= 0 then
    -- Focus the terminal window if it's visible
    local win_found = false
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) == term_bufnr then
        vim.api.nvim_set_current_win(win)
        win_found = true
        break
      end
    end

    -- If not visible, open a vertical split and attach the buffer
    if not win_found then
      vim.cmd("vs")
      vim.api.nvim_win_set_buf(0, term_bufnr)
    end

    -- Send the text to the terminal and enter insert mode
    vim.api.nvim_chan_send(chan, quote)
    vim.cmd("startinsert")
  else
    vim.notify("Rookie AI: Terminal channel not found", vim.log.levels.ERROR)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("RkAiTermToggle", function()
    M.toggle_term()
  end, { desc = "Toggle Rookie AI Terminal" })

  vim.api.nvim_create_user_command("RkAiAddLines", function(opts)
    M.add_lines(opts)
  end, { range = true, desc = "Add selected lines to AI terminal" })
end

return M
