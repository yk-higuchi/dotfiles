local map = vim.keymap.set

-- fzf-lua ------------------------------------------------------------------
-- .gitignore に書かれていないことが多いビルド成果物を検索対象から外す
local excludes = { ".git", "build", ".gradle", ".kotlin", "out", "target", ".idea", ".build", "DerivedData", "Pods" }

local fd_opts = "--color=never --hidden --type f --type l"
local rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden"
for _, dir in ipairs(excludes) do
  fd_opts = fd_opts .. " --exclude " .. dir
  rg_opts = rg_opts .. " -g '!" .. dir .. "/'"
end

local fzf = require("fzf-lua")
fzf.setup({
  defaults = { file_icons = false, git_icons = false },
  files = { fd_opts = fd_opts },
  grep = { rg_opts = rg_opts .. " -e" },
})

map("n", "<leader>ff", fzf.files, { desc = "Files" })
map("n", "<leader>sg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
map("v", "<leader>fw", fzf.grep_visual, { desc = "Grep selection" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Diagnostics (buffer)" })
map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Diagnostics (workspace)" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Symbols (buffer)" })
map("n", "<leader>fS", fzf.lsp_live_workspace_symbols, { desc = "Symbols (workspace)" })
map("n", "<leader>f.", fzf.resume, { desc = "Resume last picker" })

-- nvim-tree（ディレクトリツリー）-------------------------------------------------
require("nvim-tree").setup({
  -- `nvim .` などディレクトリを開いたときも netrw ではなく nvim-tree で表示する
  disable_netrw = true,
  sync_root_with_cwd = true,
  -- 今開いているファイルの位置へツリーを追従させる
  update_focused_file = { enable = true },
  view = { width = 35 },
  renderer = {
    -- src/main/java/com/example のような中身 1 つのディレクトリを 1 行にまとめる
    group_empty = true,
    highlight_git = "name",
    icons = {
      show = { file = false, folder = false, folder_arrow = true, git = false },
      glyphs = { folder = { arrow_closed = "▸", arrow_open = "▾" } },
    },
  },
  -- jdtls が生成する Eclipse 用ファイルも隠す（ツリー上で U を押すと一時的に表示）
  filters = { custom = { "^\\.git$", "^\\.gradle$", "^\\.classpath$", "^\\.project$", "^\\.settings$" } },
})
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- gitsigns -----------------------------------------------------------------
require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local o = function(desc) return { buffer = buf, desc = desc } end
    map("n", "]h", function() gs.nav_hunk("next") end, o("Next hunk"))
    map("n", "[h", function() gs.nav_hunk("prev") end, o("Prev hunk"))
    map("n", "<leader>gp", gs.preview_hunk, o("Preview hunk"))
    map("n", "<leader>gr", gs.reset_hunk, o("Reset hunk"))
    map("n", "<leader>gb", gs.blame_line, o("Blame line"))
  end,
})

require("nvim-autopairs").setup()
