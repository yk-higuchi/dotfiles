-- Mason ---------------------------------------------------------------------
require("mason").setup({
  -- 先に書いたレジストリが優先される（lua/mason_overrides で kotlin-lsp の URL を修正）
  registries = { "lua:mason_overrides", "github:mason-org/mason-registry" },
})

-- 起動時に未インストールのツールを入れる
-- Swift の sourcekit-lsp は Xcode 付属、Rust の rust-analyzer は rustup で入れるので不要
local ensure_installed = {
  "jdtls",
  "kotlin-lsp",
  "lua-language-server",
  "ktlint",
  "google-java-format",
  "stylua",
  "vtsls",
  "eslint-lsp",
  "prettier",
  "biome",
  "gopls",
  "goimports",
  "gofumpt",
  "pyright",
  "ruff",
  "bash-language-server",
  "shellcheck",
  "shfmt",
}

-- lua/mason_overrides で URL を修正しているパッケージ。
-- 新しい端末の初回起動時は公式レジストリがまだ無く修正が効かないため、次回起動まで待つ
local needs_override = { ["kotlin-lsp"] = true }

local registry = require("mason-registry")
registry.refresh(function()
  for _, name in ipairs(ensure_installed) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() and not pkg:is_installing() then
      if needs_override[name] and not require("mason_overrides")[name] then
        vim.notify("[mason] " .. name .. " は Neovim を再起動するとインストールされます")
      else
        vim.notify("[mason] installing " .. name)
        pkg:install()
      end
    end
  end
end)

-- LSP サーバー ----------------------------------------------------------------
-- 設定の中身は nvim-lspconfig の lsp/*.lua を使い、差分だけ上書きする
-- Java は nvim-jdtls から起動する（ftplugin/java.lua）
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      hints = { parameterNames = true, assignVariableTypes = true, compositeLiteralFields = true },
    },
  },
})

vim.lsp.config("pyright", {
  settings = {
    -- import の整理は Ruff に任せる
    pyright = { disableOrganizeImports = true },
  },
  -- プロジェクト直下の .venv があれば、その Python でライブラリを解決する
  before_init = function(_, config)
    local python = config.root_dir and vim.fs.joinpath(config.root_dir, ".venv", "bin", "python")
    if python and vim.uv.fs_stat(python) then
      config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = python })
    end
  end,
})

vim.lsp.config("ruff", {
  -- hover は pyright のものを使う
  on_attach = function(client) client.server_capabilities.hoverProvider = false end,
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      -- 保存時のチェックに clippy を使う
      check = { command = "clippy" },
    },
  },
})

-- eslint / biome はプロジェクトに設定ファイルがあるときだけ起動する
vim.lsp.enable({
  "kotlin_lsp",
  "sourcekit",
  "lua_ls",
  "vtsls",
  "eslint",
  "biome",
  "gopls",
  "pyright",
  "ruff",
  "rust_analyzer",
  "bashls",
})

-- キーマップ -------------------------------------------------------------------
-- Neovim 標準: K=hover, grn=rename, gra=code action, grr=references,
--              gri=implementation, gO=document symbols, [d / ]d=diagnostic
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
  callback = function(ev)
    local fzf = require("fzf-lua")
    local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc }) end

    map("gd", fzf.lsp_definitions, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gy", fzf.lsp_typedefs, "Goto type definition")
    map("grr", fzf.lsp_references, "References")
    map("gri", fzf.lsp_implementations, "Implementations")
    map("<leader>ca", fzf.lsp_code_actions, "Code action")
    map("<leader>cr", vim.lsp.buf.rename, "Rename")
    map(
      "<leader>ch",
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf }) end,
      "Toggle inlay hints"
    )
  end,
})
