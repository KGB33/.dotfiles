# Fzf 
set -U FZF_TMUX 1
set -U FZF_TMUX_OPTS '-p 80%,40%'

set -U FZF_DEFAULT_COMMAND 'fd --type file --follow --hidden --exclude .git'

set FZF_GRUVBOX '--color=spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'

set -U FZF_DEFAULT_OPTS "$FZF_GRUVBOX"
set -U FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -U FZF_CTRL_T_OPTS "--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"
set -U FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:wrap --bind '?:toggle-preview'"
