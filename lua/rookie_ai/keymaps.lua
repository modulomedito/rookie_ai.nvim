local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>tm", "<cmd>RkAiTermToggle<CR>", { desc = "Toggle Rookie AI Terminal" })
  vim.keymap.set("v", "<leader>aia", ":RkAiAddLines<CR>", { desc = "Add selected lines to AI terminal" })
end

return M
