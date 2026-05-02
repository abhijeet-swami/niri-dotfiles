# ============================================================
# ZSH CONFIG
# ============================================================

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS       # don't save duplicate commands
setopt HIST_IGNORE_SPACE      # don't save commands starting with space
setopt SHARE_HISTORY          # share history across terminals
setopt HIST_VERIFY            # show command before running from history

# --- Completion (the folder autocomplete you want) ---
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select                   # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case insensitive: type 'dow' matches 'Downloads'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*' group-name ''

# Tab once = complete, Tab again = cycle through options
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# --- Navigation ---
setopt AUTO_CD          # type folder name to cd into it
setopt AUTO_PUSHD       # cd pushes to stack (use popd to go back)
setopt PUSHD_IGNORE_DUPS

# --- Plugins ---
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# history search with up/down arrows
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- FZF (fuzzy search everything) ---
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Ctrl+R = fuzzy search history
# Ctrl+T = fuzzy file picker
# Alt+C  = fuzzy cd into directory

# --- Zoxide (smarter cd - remembers where you go) ---
eval "$(zoxide init zsh)"
# Now type 'z dow' to jump to ~/Downloads from anywhere

# --- Aliases ---
# ls replacements with eza (better ls)
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias lt='eza -la --icons --tree --level=2'
alias la='eza -a --icons'

# cat replacement
alias cat='bat'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# system
alias update='sudo pacman -Syu && yay -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "Nothing to remove"'
alias ports='ss -tulnp'
alias myip='curl ifconfig.me'

# niri
alias niricfg='nvim ~/.config/niri/config.kdl'
alias nirireload='niri msg action do-screen-transition'

# confirm before overwrite
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

alias ff='~/.config/bin/ff-random.sh'
alias fastfetch='~/.config/bin/ff-random.sh'

# --- Autosuggestion settings ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'        # dimmed gray suggestion color
ZSH_AUTOSUGGEST_STRATEGY=(history completion) # suggest from history first, then completion

# --- Syntax highlighting colors ---
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

# --- Starship prompt ---
eval "$(starship init zsh)"

