-- kickstart.nvim の方針に合わせ、Neovim 標準のキーで足りるものは標準を使う
-- 標準: [b / ]b=バッファ移動, [d / ]d=診断移動, <C-w>d=診断のフロート表示
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>pu", function() vim.pack.update() end, { desc = "Update plugins" })
-- 別の端末で更新された nvim-pack-lock.json を pull したあと、そのバージョンにそろえる
map(
  "n",
  "<leader>ps",
  function() vim.pack.update(nil, { target = "lockfile" }) end,
  { desc = "Sync plugins to lockfile" }
)
