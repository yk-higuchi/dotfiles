-- nvim-dbee（DB クライアント）
-- 接続先は UI の「add」から登録すると、既定の保存先（JSON ファイル）に保存される
require("dbee").setup({
  -- Nerd Font を使わないので、ツリーと実行履歴のアイコンを無効にする
  drawer = { disable_candies = true },
  call_log = { disable_candies = true },
})

vim.keymap.set("n", "<leader>D", function() require("dbee").toggle() end, { desc = "Database UI" })
