# Git Dotfiles
alias .git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Activate python venvs and auto-update pip
alias venv='. .venv/bin/activate && python -m pip install --upgrade pip'

# Special tree to ignore special python files
alias pytree='tree -a -I ".venv|*.pyc|.git|.mypy*|.pytest*|*.egg-info" --prune --dirsfirst --matchdirs '

# Exa
alias ls="exa -F --group-directories-first"
alias la="exa -Fa --group-directories-first"
alias ll="exa -Flbha --git --group-directories-first"
alias lt="exa -TF --git-ignore --group-directories-first"

