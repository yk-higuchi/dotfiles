require("blink.cmp").setup({
  -- <C-y> で確定、<C-n>/<C-p> で選択、<C-space> で手動表示
  keymap = { preset = "default" },
  completion = {
    -- Nerd Font を使わないので、種類はアイコンではなく文字（Function, Class など）で表示する
    menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
