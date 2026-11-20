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
-- vim.ui.select（jdtls の選択肢、vim.lsp.buf.code_action など）も fzf で表示する
fzf.register_ui_select()

map("n", "<leader>sf", fzf.files, { desc = "Files" })
map("n", "<leader>sg", fzf.live_grep, { desc = "Grep" })
map("n", "<leader>sw", fzf.grep_cword, { desc = "Word under cursor" })
map("v", "<leader>sw", fzf.grep_visual, { desc = "Selection" })
map("n", "<leader>sh", fzf.helptags, { desc = "Help" })
map("n", "<leader>sk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>sc", fzf.commands, { desc = "Commands" })
map("n", "<leader>sd", fzf.diagnostics_document, { desc = "Diagnostics (buffer)" })
map("n", "<leader>sD", fzf.diagnostics_workspace, { desc = "Diagnostics (workspace)" })
map("n", "<leader>sr", fzf.resume, { desc = "Resume" })
map("n", "<leader>s.", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>ss", fzf.builtin, { desc = "Pickers" })
map("n", "<leader>sn", function() fzf.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Neovim config" })
map("n", "<leader>s/", fzf.lines, { desc = "Grep open buffers" })
map("n", "<leader>/", fzf.blines, { desc = "Search in buffer" })
map("n", "<leader><leader>", fzf.buffers, { desc = "Buffers" })

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

-- gitsigns（gitsigns の README / kickstart.nvim の推奨配置）-------------------------
require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local o = function(desc) return { buffer = buf, desc = desc } end
    -- diff モードでは本来の ]c / [c（差分の移動）を使う
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, o("Next git change"))
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, o("Prev git change"))

    local range = function() return { vim.fn.line("."), vim.fn.line("v") } end
    map("v", "<leader>hs", function() gs.stage_hunk(range()) end, o("Stage hunk"))
    map("v", "<leader>hr", function() gs.reset_hunk(range()) end, o("Reset hunk"))
    map("n", "<leader>hs", gs.stage_hunk, o("Stage hunk"))
    map("n", "<leader>hr", gs.reset_hunk, o("Reset hunk"))
    map("n", "<leader>hS", gs.stage_buffer, o("Stage buffer"))
    map("n", "<leader>hR", gs.reset_buffer, o("Reset buffer"))
    map("n", "<leader>hp", gs.preview_hunk, o("Preview hunk"))
    map("n", "<leader>hi", gs.preview_hunk_inline, o("Preview hunk inline"))
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, o("Blame line"))
    map("n", "<leader>hd", gs.diffthis, o("Diff against index"))
    map("n", "<leader>hD", function() gs.diffthis("~") end, o("Diff against last commit"))
    map("n", "<leader>hq", gs.setqflist, o("Hunks to quickfix (file)"))
    map("n", "<leader>hQ", function() gs.setqflist("all") end, o("Hunks to quickfix (repo)"))
    map("n", "<leader>tb", gs.toggle_current_line_blame, o("Toggle line blame"))
    map("n", "<leader>tw", gs.toggle_word_diff, o("Toggle word diff"))
    map({ "o", "x" }, "ih", gs.select_hunk, o("Inside hunk"))
  end,
})

require("nvim-autopairs").setup()
