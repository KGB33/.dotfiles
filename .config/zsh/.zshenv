# Used for setting user's environment variables;
# it should not contain commands that produce output
# or assume the shell is attached to a TTY.
# When this file exists it will always be read.

# Task Warrior config location
export TASKRC=~/.config/taskwarrior/.taskrc
export TASKDATA=~/.config/taskwarrior/.task_data

# Set TERMINAL for app launcher
export TERMINAL="kitty"

# Opt out of Microsoft .NET telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_HTTPREPL_TELEMETRY_OPTOUT=1

# Fzf 
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"
