# SHADOWX // NOIR shell
[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc
[[ $- != *i* ]] && return
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
if command -v fastfetch >/dev/null 2>&1 && [[ -f "$HOME/.config/fastfetch/config.jsonc" ]]; then
    fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
fi
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
