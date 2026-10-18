-- Mason 用の上書きレジストリ（lsp.lua で公式レジストリより優先して登録する）
--
-- 公式レジストリの kotlin-lsp は download-cdn.jetbrains.com を直接参照しているが、
-- CDN が署名付き URL 必須になったため 404 になる。公式レジストリの定義を読み込み、
-- URL のホストだけ download.jetbrains.com（署名付き URL へリダイレクトされる）に差し替える。
-- バージョンは公式レジストリに追従し、公式側が直れば差し替えは何もしなくなる。
local patches = {
  ["kotlin-lsp"] = { from = "download%-cdn%.jetbrains%.com", to = "download.jetbrains.com" },
}

local registry_json = vim.fs.joinpath(
  vim.fn.stdpath("data"),
  "mason",
  "registries",
  "github",
  "mason-org",
  "mason-registry",
  "registry.json"
)

local function replace_all(value, patch)
  if type(value) == "string" then
    return (value:gsub(patch.from, patch.to))
  elseif type(value) == "table" then
    local result = {}
    for k, v in pairs(value) do
      result[k] = replace_all(v, patch)
    end
    return result
  end
  return value
end

local index = {}

-- 初回起動時は公式レジストリがまだ無いので何もしない（次回起動から有効）
local file = io.open(registry_json, "r")
if not file then return index end
local ok, specs = pcall(vim.json.decode, file:read("*a"))
file:close()
if not ok then return index end

for _, spec in ipairs(specs) do
  local patch = patches[spec.name]
  if patch then
    local mod = "mason_overrides." .. spec.name
    local patched = replace_all(spec, patch)
    package.preload[mod] = function() return patched end
    index[spec.name] = mod
  end
end

return index
