local M = {}

function M.setup(opts)
    -- Initialize commands and keymaps
    require("rookie_ai.commands").setup()
    require("rookie_ai.keymaps").setup()
end

return M
