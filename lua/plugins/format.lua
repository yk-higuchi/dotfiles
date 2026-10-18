require("conform").setup({
  formatters_by_ft = {
    kotlin = { "ktlint" },
    java = { "google-java-format" },
    swift = { "swift_format" },
    lua = { "stylua" },
    javascript = { "biome", "prettier", stop_after_first = true },
    javascriptreact = { "biome", "prettier", stop_after_first = true },
    typescript = { "biome", "prettier", stop_after_first = true },
    typescriptreact = { "biome", "prettier", stop_after_first = true },
    go = { "goimports", "gofumpt" },
    python = { "ruff_organize_imports", "ruff_format" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  formatters = {
    -- Xcode 付属の swift-format を使う
    swift_format = { command = "xcrun", prepend_args = { "swift-format" } },
    -- biome.json があるプロジェクトだけ Biome を使い、それ以外は Prettier に任せる
    biome = { require_cwd = true },
    -- 2 スペースでインデントする（.editorconfig より優先される）
    shfmt = { prepend_args = { "-i", "2" } },
  },
  -- 保存時の自動フォーマットは :FormatToggle で切り替え
  format_on_save = function(buf)
    if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then return end
    return { timeout_ms = 3000, lsp_format = "fallback" }
  end,
})

vim.api.nvim_create_user_command("FormatToggle", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("Format on save: " .. (vim.g.disable_autoformat and "off" or "on"))
end, {})

vim.keymap.set(
  { "n", "v" },
  "<leader>cf",
  function() require("conform").format({ lsp_format = "fallback" }) end,
  { desc = "Format" }
)
