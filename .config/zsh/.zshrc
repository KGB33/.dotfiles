# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zhs/histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob
unsetopt beep notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '$ZDOTDIR/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Note: The $ZDOTDIR environment variable is set by the file `/etc/zsh/zshenv`
# See this SO post for more Info
# https://stackoverflow.com/questions/21162988/how-to-make-zsh-search-configuration-in-xdg-config-home
# TODO: swap this to a systemd-homed variable when I move over to it


# Source addtional files
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

# Shell Add-ins
eval "$(pyenv init -)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

