[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by Toolbox App
PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

export PATH

# Added by `rbenv init` on Sat Nov  1 18:00:48 JST 2025
command -v rbenv >/dev/null && eval "$(rbenv init - --no-rehash zsh)"
