local M = {}

function M.setup(opts)
    -- Initialize commands and keymaps
    require("rookie_ai.commands").setup()
    require("rookie_ai.keymaps").setup()
end

--- Statusline component: returns the current AI terminal number (1-4),
--- or an empty string when no terminal is active.
---@return string
function M.statusline()
    local index = require("rookie_ai.commands").get_current_index()
    if not index then
        return ""
    end
    return string.format(" RK-AI:%d", index)
end

return M
