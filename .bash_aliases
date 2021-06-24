# Git Dotfiles
alias .git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Activate python venvs and auto-update pip
alias venv='. .venv/bin/activate && python -m pip install --upgrade pip'

# Special tree to ignore special python files
alias pytree='tree -a -I ".venv|*.pyc|.git|.mypy*|.pytest*|*.egg-info" --prune --dirsfirst --matchdirs '

# Exa
alias ls="exa -F --group-directories-first --icons"
alias la="exa -Fa --group-directories-first --icons"
alias ll="exa -Flbha --git --group-directories-first --icons"
alias lt="exa -TF --git-ignore --group-directories-first --icons"

# When SSH breaks, use ssk to copy kitty terminfo over
# https://sw.kovidgoyal.net/kitty/faq.html
#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-when-sshing-into-a-different-computer
alias ssk="kitty +kitten ssh"
