# Used for setting user's environment variables;
# it should not contain commands that produce output
# or assume the shell is attached to a TTY.
# When this file exists it will always be read.

# Task Warrior config location
export TASKRC=~/.config/taskwarrior/.taskrc
export TASKDATA=~/.config/taskwarrior/.task_data

# Pyenv variables
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
