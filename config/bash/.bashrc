# ═══════════════════════════════════════════════════════════════
#  SHADOWX // NOIR — bash startup
#  Personal overrides: ~/.bashrc.local
# ═══════════════════════════════════════════════════════════════

[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

if command -v fastfetch >/dev/null 2>&1 && [[ -f "$HOME/.config/kitty/fastfetch.jsonc" ]]; then
    fastfetch --config "$HOME/.config/kitty/fastfetch.jsonc"
fi

[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
