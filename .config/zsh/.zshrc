# Note: The $ZDOTDIR environment variable is managed by systemd-homed
# this is required to load the variable before the shell.
# It must be set to the folder that this file resides in.


# histfile settings
HISTFILE=~/.config/zhs/histfile
HISTSIZE=1000
SAVEHIST=1000


setopt autocd extendedglob
unsetopt beep notify

autoload -Uz compinit
compinit

# Vi Mode
bindkey -v
export KEYTIMEOUT=1


# Source alias
if [ -f $ZDOTDIR/.zsh_aliases ]; then
    . $ZDOTDIR/.zsh_aliases
fi


# Set additional PATH stuff
export PATH="$HOME/.poetry/bin:$PATH" # Poetry
export PATH="$HOME/.local/bin:$PATH" # Black
export PATH="$HOME/.gem/ruby/2.7.0/bin:$PATH" # Ruby
export PATH="$HOME/go/bin:$PATH" # Go packages

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Set Nvim to the man page reader
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# ======== Load & Configure 'plugins' ======== 

# z.sh -- https://github.com/rupa/z
export _Z_DATA="$ZDOTDIR/plugins/z/z.data"
. $ZDOTDIR/plugins/z/z.sh



# Shell Add-ins
eval "$(pyenv init -)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# Adds Syntax highlighting -- Installed via community/zsh-syntax-highlighting
# Needs to be the last thing sourced to highlight properly
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
