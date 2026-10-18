vim.cmd.colorscheme("tokyonight-night")

require("lualine").setup({
  options = {
    icons_enabled = false,
    component_separators = "|",
    section_separators = "",
    globalstatus = true,
  },
})

-- jdtls のプロジェクト読み込みなど、LSP の進捗を右下に表示する
require("fidget").setup()

local wk = require("which-key")
wk.setup({ icons = { mappings = false } })
wk.add({
  { "<leader>f", group = "Find" },
  { "<leader>s", group = "Search" },
  { "<leader>c", group = "Code" },
  { "<leader>g", group = "Git" },
  { "<leader>p", group = "Plugins" },
  { "<leader>j", group = "Java" },
})
