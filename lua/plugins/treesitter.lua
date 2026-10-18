local parsers = {
  "kotlin",
  "java",
  "swift",
  "groovy", -- build.gradle
  "javascript",
  "typescript",
  "tsx",
  "jsdoc",
  "html",
  "css",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "python",
  "rust",
  "xml",
  "json",
  "yaml",
  "toml",
  "properties",
  "lua",
  "vim",
  "vimdoc",
  "markdown",
  "markdown_inline",
  "bash",
  "gitignore",
}

-- 未インストールのパーサーだけ非同期でビルドする（tree-sitter CLI が必要）
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then return end
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
