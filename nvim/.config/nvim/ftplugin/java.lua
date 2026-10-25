local ok, jdtls = pcall(require, "jdtls")
if not ok then return end

-- マルチモジュールでもルートを掴めるよう、ビルドツールのマーカーを優先する
local root_dir = vim.fs.root(0, {
  { "gradlew", "mvnw", "settings.gradle", "settings.gradle.kts" },
  { "pom.xml", "build.gradle", "build.gradle.kts" },
  { ".git" },
})
if not root_dir then return end

-- プロジェクトごとに jdtls のワークスペース（インデックス）を分ける
local project = vim.fs.basename(root_dir) .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)
local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", project)

-- SDKMAN の JDK を jdtls に登録する（メジャーバージョンごとに最初に見つかったもの）
local runtimes, seen = {}, {}
local sdkman_java = vim.fs.joinpath(vim.env.HOME, ".sdkman", "candidates", "java")
for name, type in vim.fs.dir(sdkman_java) do
  local major = name:match("^(%d+)%.")
  if type == "directory" and major and not seen[major] then
    seen[major] = true
    table.insert(runtimes, { name = "JavaSE-" .. major, path = vim.fs.joinpath(sdkman_java, name) })
  end
end

-- jdtls 本体は JDK 25 で動かす。sdk use / sdk env で JAVA_HOME が 21 などになっていても左右されないよう明示する
local function jdtls_java()
  -- 一時的に別の JDK を試したいときは JDTLS_JAVA_HOME で上書きできる
  if vim.env.JDTLS_JAVA_HOME then return vim.fs.joinpath(vim.env.JDTLS_JAVA_HOME, "bin", "java") end

  -- SDKMAN の 25 系から一番新しいものを選ぶ（同じバージョンは名前順で決める）
  local best, best_ver
  for name, type in vim.fs.dir(sdkman_java) do
    local ver = type == "directory" and name:match("^25%.") and vim.version.parse(name:match("^[%d.]+"))
    if ver and (not best_ver or ver > best_ver or (ver == best_ver and name > best)) then
      best, best_ver = name, ver
    end
  end
  if best then return vim.fs.joinpath(sdkman_java, best, "bin", "java") end

  -- SDKMAN 以外で入れた JDK（macOS 標準の java_home）
  local out = vim.fn.system({ "/usr/libexec/java_home", "-v", "25" })
  if vim.v.shell_error == 0 then return vim.fs.joinpath(vim.trim(out), "bin", "java") end
end

local cmd = { "jdtls", "-data", workspace_dir }
local java = jdtls_java()
if java then
  table.insert(cmd, "--java-executable=" .. java)
else
  vim.notify("JDK 25 が見つからないため、JAVA_HOME の Java で jdtls を起動します", vim.log.levels.WARN)
end
local lombok = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "share", "jdtls", "lombok.jar")
if vim.uv.fs_stat(lombok) then table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok) end

-- dynamicRegistration が有効だと、jdtls はプロジェクトの読み込みが終わるまで定義ジャンプ等を
-- 登録せず「server does not support」になる。静的に登録させて起動直後から使えるようにする
local capabilities = require("blink.cmp").get_lsp_capabilities()
for _, method in ipairs({ "definition", "declaration", "typeDefinition", "implementation", "references" }) do
  capabilities.textDocument[method] =
    vim.tbl_extend("force", capabilities.textDocument[method] or {}, { dynamicRegistration = false })
end

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      configuration = { runtimes = runtimes },
      signatureHelp = { enabled = true },
      inlayHints = { parameterNames = { enabled = "all" } },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.assertj.core.api.Assertions.*",
        },
      },
      sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
    },
  },
})

local map = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc }) end
map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
map("n", "<leader>jv", jdtls.extract_variable, "Extract variable")
map("v", "<leader>jv", function() jdtls.extract_variable(true) end, "Extract variable")
map("n", "<leader>jc", jdtls.extract_constant, "Extract constant")
map("v", "<leader>jm", function() jdtls.extract_method(true) end, "Extract method")
