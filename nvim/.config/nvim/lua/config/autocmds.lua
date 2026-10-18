local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function() vim.hl.on_yank() end,
})

-- 保存時に使うフォーマッタの既定のインデント幅に合わせる（lua/plugins/format.lua）
-- ここに無い言語は options.lua の 4 スペース（ktlint / Ruff / rustfmt と同じ）。
-- Go は Neovim 標準の設定でタブ（gofumpt と同じ）。
-- プロジェクトに .editorconfig があれば、そちらが優先される。
local indent_width = {
  java = 2, -- google-java-format
  swift = 2, -- swift-format
  javascript = 2, -- Prettier
  javascriptreact = 2,
  typescript = 2,
  typescriptreact = 2,
  sh = 2, -- shfmt（-i 2 を指定）
  bash = 2,
  zsh = 2,
  lua = 2, -- stylua（stylua.toml で 2 スペースを指定）
}

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = vim.tbl_keys(indent_width),
  callback = function(ev)
    local width = indent_width[ev.match]
    vim.bo[ev.buf].shiftwidth = width
    vim.bo[ev.buf].tabstop = width
  end,
})
