# dotfiles

macOS 用の設定ファイル。[GNU Stow](https://www.gnu.org/software/stow/) でホームディレクトリにシンボリックリンクを張って使う。

## パッケージ

| パッケージ | リンク先 |
| --- | --- |
| `zsh` | `~/.zshrc`、`~/.zprofile`、`~/.zshenv` |
| `starship` | `~/.config/starship.toml` |
| `ghostty` | `~/.config/ghostty/config`（Ghostty と cmux が読み込む） |
| `nvim` | `~/.config/nvim`（ディレクトリごとリンクする） |

## セットアップ

```sh
git clone git@github.com:yk-higuchi/dotfiles.git ~/dotfiles
brew bundle --file ~/dotfiles/Brewfile
cd ~/dotfiles && stow zsh starship ghostty nvim
```

既存の `~/.zshrc` や `~/.config/nvim` などがあると Stow はリンクを張らずに止まるので、退避してから実行する。

`.zshrc` が初期化する各ツール（kubectl、pyenv、fnm、direnv、SDKMAN、rbenv など）は、入っている場合だけ読み込まれる。

## 端末固有の設定

端末ごとに変えたい設定や、トークンなどの秘密情報は `~/.zshrc.local` に書く。このファイルは git 管理しない。

## 変更の反映

`~/.zshrc` などはこのリポジトリへのリンクなので、どちらを編集しても同じファイルが変わる。新しいパッケージを追加したときは `stow <パッケージ名>` を実行する。

## Neovim

Neovim 0.12 の設定。プラグイン管理は標準の `vim.pack`、LSP は標準の `vim.lsp.config` / `vim.lsp.enable` を使う。

### 対応言語

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

### 初回起動

`stow nvim` のあと `nvim` を起動し、プラグインのインストール確認を承認する。

- Treesitter のパーサーと Mason のツールはバックグラウンドで自動インストールされる（数分かかる）。
- kotlin-lsp は「再起動するとインストールされます」と通知されるので、Neovim をもう一度起動する。

使う言語に応じて、次も入れておく。

| 用途 | 必要なもの |
| --- | --- |
| JS / TS / Python / Shell の LSP（Mason が npm で入れる） | Node.js |
| Go の LSP・フォーマッタ（Mason が `go install` で入れる） | Go |
| Rust | rustup と `rustup component add rust-analyzer` |
| Java / Kotlin | Java 21 以上（SDKMAN の JDK は jdtls に自動登録される） |
| Swift | Xcode |

### プラグインの運用

- プラグインを更新する：`<Space>pu` で差分を確認して反映し、`nvim/.config/nvim/nvim-pack-lock.json` をコミットする。
- 別の端末で pull したあと：Neovim を再起動し（新しいプラグインが入る）、`<Space>ps` でロックファイルのバージョンにそろえる。
- 不要になったプラグインは `git diff -- nvim/.config/nvim/nvim-pack-lock.json` で確認し、`:lua vim.pack.del({ "名前" })` で削除する。

### 構成（`nvim/.config/nvim/`）

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
