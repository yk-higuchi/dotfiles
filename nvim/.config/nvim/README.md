# nvim-config

Neovim 0.12 の設定。プラグイン管理は標準の `vim.pack`、LSP は標準の `vim.lsp.config` / `vim.lsp.enable` を使う。

## 対応言語

| 言語 | LSP | フォーマッタ |
| --- | --- | --- |
| Java | jdtls（nvim-jdtls） | google-java-format |
| Kotlin | kotlin-lsp | ktlint |
| Swift | sourcekit-lsp（Xcode 付属） | swift-format（Xcode 付属） |
| JavaScript / TypeScript | vtsls、ESLint、Biome | Biome（`biome.json` がある場合）/ Prettier |
| Go | gopls | goimports + gofumpt |
| Python | Pyright、Ruff | Ruff |
| Rust | rust-analyzer（rustup） | rustfmt |
| Shell | bash-language-server（+ ShellCheck） | shfmt |
| Lua | lua-language-server | StyLua |

## セットアップ（macOS）

1. 外部ツールを入れる

   ```sh
   brew bundle --file ~/.config/nvim/Brewfile
   ```

   使う言語に応じて、次も入れておく。

   | 用途 | 必要なもの |
   | --- | --- |
   | JS / TS / Python / Shell の LSP（Mason が npm で入れる） | Node.js |
   | Go の LSP・フォーマッタ（Mason が `go install` で入れる） | Go |
   | Rust | rustup と `rustup component add rust-analyzer` |
   | Java / Kotlin | Java 21 以上（SDKMAN の JDK は jdtls に自動登録される） |
   | Swift | Xcode |

2. 設定を取得する

   ```sh
   git clone git@github.com:yk-higuchi/nvim-config.git ~/.config/nvim
   ```

3. `nvim` を起動し、プラグインのインストール確認を承認する

   - Treesitter のパーサーと Mason のツールはバックグラウンドで自動インストールされる（数分かかる）。
   - kotlin-lsp は「再起動するとインストールされます」と通知されるので、Neovim をもう一度起動する。

## 運用

- プラグインを更新する：`<Space>pu` で差分を確認して反映し、`nvim-pack-lock.json` をコミットする。
- 別の端末で pull したあと：Neovim を再起動し（新しいプラグインが入る）、`<Space>ps` でロックファイルのバージョンにそろえる。
- 不要になったプラグインは `git diff -- nvim-pack-lock.json` で確認し、`:lua vim.pack.del({ "名前" })` で削除する。

## 構成

```
init.lua                 Leader キーの設定と各モジュールの読み込み
ftplugin/java.lua        jdtls の起動設定
lua/config/              エディタの基本設定、キーマップ、autocmd
lua/plugins/init.lua     vim.pack.add による全プラグインの登録
lua/plugins/*.lua        プラグインごとの設定
lua/mason_overrides/     Mason 公式レジストリの kotlin-lsp の URL を修正する上書きレジストリ
stylua.toml              設定ファイル自体の整形ルール
nvim-pack-lock.json      プラグインのバージョン固定
```
