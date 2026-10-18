# 共有しても安全なように、各ツールは入っている場合だけ初期化する。
# 端末固有の設定や秘密情報は ~/.zshrc.local（git 管理外）に書く。

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi

if command -v kubectl >/dev/null; then
  source <(kubectl completion zsh)
  alias k="kubectl"
  compdef k=kubectl
fi
command -v terraform >/dev/null && complete -o nospace -C "$(command -v terraform)" terraform

[[ -f "${HOME}/.deno/env" ]] && . "${HOME}/.deno/env"

# ~/go/go<バージョン> のうち最新の安定版を使う（go1.28rc1 などのプレリリース版は除く）
go_root=$(find "${HOME}/go" -mindepth 1 -maxdepth 1 -type d -name 'go[0-9]*' 2>/dev/null | grep -E '/go[0-9]+\.[0-9]+(\.[0-9]+)?$' | sort -V | tail -n 1)
export ANDROID_HOME="${HOME}/Library/Android/sdk"
if [[ -d "${ANDROID_HOME}" ]]; then
  android_build_tool_version=$(find "${ANDROID_HOME}/build-tools" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V | tail -n 1)
  android_build_tool_version=${android_build_tool_version##*/}
  PATH="${PATH}:${ANDROID_HOME}/platform-tools"
  PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
  PATH="${PATH}:${ANDROID_HOME}/build-tools/${android_build_tool_version}"
fi
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
[[ -n "${go_root}" ]] && PATH="${PATH}:${go_root}/bin"
# go install で入れたツール
PATH="${PATH}:${HOME}/go/bin"
PATH="$HOME/.local/bin:$PATH"
export PATH

# GitHub などへの SSH 鍵はスマートカード上にあり、gpg-agent 経由で使う
if command -v gpgconf >/dev/null; then
  export GPG_TTY=$(tty)
  gpgconf --launch gpg-agent
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

command -v starship >/dev/null && eval "$(starship init zsh)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init - zsh)"

command -v direnv >/dev/null && eval "$(direnv hook zsh)"

command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# 端末固有の設定（git 管理外）
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
