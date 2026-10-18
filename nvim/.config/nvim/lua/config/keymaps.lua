local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

map("n", "<leader>pu", function() vim.pack.update() end, { desc = "Update plugins" })
-- 別の端末で更新された nvim-pack-lock.json を pull したあと、そのバージョンにそろえる
map(
  "n",
  "<leader>ps",
  function() vim.pack.update(nil, { target = "lockfile" }) end,
  { desc = "Sync plugins to lockfile" }
)
