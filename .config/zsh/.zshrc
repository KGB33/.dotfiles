# Note: The $ZDOTDIR environment variable is managed by systemd-homed
# this is required to load the variable before the shell.
# It must be set to the folder that this file resides in.


# histfile settings
HISTFILE=~/.config/zsh/histfile
HISTSIZE=1000
SAVEHIST=1000
setopt INC_APPEND_HISTORY_TIME


setopt autocd extendedglob
unsetopt beep notify

autoload -Uz compinit
compinit

# Vi Mode
bindkey -v
export KEYTIMEOUT=500


# Source alias
if [ -f $ZDOTDIR/.zsh_aliases ]; then
    . $ZDOTDIR/.zsh_aliases
fi

# Source fzf keybindings
source /usr/share/fzf/key-bindings.zsh 
source /usr/share/fzf/completion.zsh
source $ZDOTDIR/plugins/fzf-git.sh
source $ZDOTDIR/plugins/fzf-cheat.zsh


# Set additional PATH stuff
export PATH="$HOME/.poetry/bin:$PATH" # Poetry
export PATH="$HOME/.local/bin:$PATH" # Black
export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH" # Ruby
export PATH="$HOME/go/bin:$PATH" # Go packages
export PATH="$HOME/.cargo/bin:$PATH" # Rust packages

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Set Nvim to the man page reader
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# Start gpg agent 
export GPG_TTY=$(tty)

# ======== Load & Configure 'plugins' ======== 

# z.sh -- https://github.com/rupa/z
export _Z_DATA="$ZDOTDIR/plugins/z/z.data"
. $ZDOTDIR/plugins/z/z.sh


# Shell Add-ins
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# Adds Syntax highlighting -- Installed via community/zsh-syntax-highlighting
# Needs to be the last thing sourced to highlight properly
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
