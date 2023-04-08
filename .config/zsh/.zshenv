# Used for setting user's environment variables;
# it should not contain commands that produce output
# or assume the shell is attached to a TTY.
# When this file exists it will always be read.

# XDG Variables
export XDG_DATA_HOME=~/.local/share 
export XDG_CONFIG_HOME=~/.config 
export XDG_STATE_HOME=~/.local/state 
export XDG_CACHE_HOME=~/.cache

export ANSIBLE_HOME="$XDG_CACHE_HOME/ansible"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GOPATH="$XDG_DATA_HOME/go"
export HISTFILE="$XDG_STATE_HOME/bash/history"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export VAGRANT_HOME="$XDG_DATA_HOME/vagrant"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"

# Task Warrior config location
#export TASKRC=~/.config/taskwarrior/.taskrc
#export TASKDATA=~/.config/taskwarrior/.task_data

# Set TERMINAL for app launcher
export TERMINAL="kitty"

# Opt out of Microsoft .NET telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_HTTPREPL_TELEMETRY_OPTOUT=1

# Fzf 
export FZF_TMUX=1
export FZF_TMUX_OPTS='-p 80%,40%'

export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'

FZF_GRUVBOX='--color=spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'

export FZF_DEFAULT_OPTS="$FZF_GRUVBOX"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap --bind '?:toggle-preview'"

# GnuPG
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg/"

# SSH-agent (managed by systemd)
unset SSH_AGENT_PID
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Poetry is super dumb 
# https://github.com/python-poetry/poetry/issues/1917
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
