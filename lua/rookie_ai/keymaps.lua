local M = {}

local toggle_commands = {
    a = "RkAiTermToggleA",
    b = "RkAiTermToggleB",
    c = "RkAiTermToggleC",
    d = "RkAiTermToggleD",
}

function M.setup()
    for label, cmd in pairs(toggle_commands) do
        vim.keymap.set(
            "n",
            "<leader>tm" .. label,
            "<cmd>" .. cmd .. "<CR>",
            { desc = "Toggle Rookie AI Terminal '" .. label .. "'" }
        )
    end

    vim.keymap.set(
        "n",
        "<leader>aif",
        "<cmd>RkAiAddFile<CR>",
        { desc = "Add file path to AI terminal" }
    )

    vim.keymap.set(
        { "n", "v" },
        "<leader>aia",
        ":RkAiAddLines<CR>",
        { desc = "Add line(s) to AI terminal" }
    )
end

return M
