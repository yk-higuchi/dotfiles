# dotfiles

macOS 用の設定ファイル。[GNU Stow](https://www.gnu.org/software/stow/) でホームディレクトリにシンボリックリンクを張って使う。

Neovim の設定は別リポジトリ（[nvim-config](https://github.com/yk-higuchi/nvim-config)）で管理している。

## パッケージ

| パッケージ | リンク先 |
| --- | --- |
| `zsh` | `~/.zshrc`、`~/.zprofile`、`~/.zshenv` |
| `starship` | `~/.config/starship.toml` |

## セットアップ

```sh
git clone git@github.com:yk-higuchi/dotfiles.git ~/dotfiles
brew bundle --file ~/dotfiles/Brewfile
cd ~/dotfiles && stow zsh starship
```

既存の `~/.zshrc` などがあると Stow はリンクを張らずに止まるので、退避してから実行する。

`.zshrc` が初期化する各ツール（kubectl、pyenv、fnm、direnv、SDKMAN、rbenv など）は、入っている場合だけ読み込まれる。

## 端末固有の設定

端末ごとに変えたい設定や、トークンなどの秘密情報は `~/.zshrc.local` に書く。このファイルは git 管理しない。

## 変更の反映

`~/.zshrc` などはこのリポジトリへのリンクなので、どちらを編集しても同じファイルが変わる。新しいパッケージを追加したときは `stow <パッケージ名>` を実行する。
