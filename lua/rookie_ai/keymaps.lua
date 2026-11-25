local M = {}

local toggle_commands = {
    ["1"] = "RkAiTermToggleA",
    ["2"] = "RkAiTermToggleB",
    ["3"] = "RkAiTermToggleC",
    ["4"] = "RkAiTermToggleD",
}

function M.setup()
    for label, cmd in pairs(toggle_commands) do
        vim.keymap.set(
            "n",
            "<leader>t" .. label,
            "<cmd>" .. cmd .. "<CR>",
            { desc = "Toggle Rookie AI Terminal '" .. label .. "'" }
        )

        vim.keymap.set(
            { "n", "v" },
            "<leader>a" .. label,
            ":RkAiAddLines " .. label .. "<CR>",
            { desc = "Add line(s) to Rookie AI Terminal '" .. label .. "'" }
        )
    end

    vim.keymap.set(
        "n",
        "<leader>aif",
        "<cmd>RkAiAddFile<CR>",
        { desc = "Add file path to AI terminal" }
    )
end

return M
