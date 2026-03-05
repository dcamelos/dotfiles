-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Mantener la selección visual después de copiar con 'y'
vim.keymap.set("v", "y", "ygv", { desc = "Copiar y mantener selección" })

-- Forzar terminal flotante con Snacks
vim.keymap.set("n", "<leader>ft", function()
  Snacks.terminal()
end, { desc = "Terminal Flotante" })
-- Si quieres una en el directorio actual
vim.keymap.set("n", "<leader>fT", function()
  Snacks.terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal Flotante (cwd)" })
