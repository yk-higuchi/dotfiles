local gh = function(repo) return "https://github.com/" .. repo end

-- インストール・更新後のビルドフック（vim.pack.add より前に登録する）
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
    -- nvim-dbee は Go 製のバックエンドを別途ダウンロードする
    if name == "nvim-dbee" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("nvim-dbee") end
      require("dbee").install()
    end
  end,
})

vim.pack.add({
  -- UI
  gh("folke/tokyonight.nvim"),
  gh("nvim-lualine/lualine.nvim"),
  gh("folke/which-key.nvim"),
  gh("j-hui/fidget.nvim"),

  -- Editor
  gh("ibhagwan/fzf-lua"),
  gh("nvim-tree/nvim-tree.lua"),
  gh("lewis6991/gitsigns.nvim"),
  gh("windwp/nvim-autopairs"),

  -- Treesitter
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

  -- Completion（1.x のタグを使うと Rust 製の本体がビルド済みで落ちてくる）
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
  gh("rafamadriz/friendly-snippets"),

  -- LSP
  gh("mason-org/mason.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("mfussenegger/nvim-jdtls"),

  -- Format
  gh("stevearc/conform.nvim"),

  -- Database
  gh("MunifTanjim/nui.nvim"),
  gh("kndndrj/nvim-dbee"),
})

require("plugins.ui")
require("plugins.editor")
require("plugins.treesitter")
require("plugins.completion")
require("plugins.lsp")
require("plugins.format")
require("plugins.database")
