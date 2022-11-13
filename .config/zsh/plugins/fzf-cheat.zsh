# Inspired by https://www.youtube.com/watch?v=hJzqEAf2U4I

if [[ $- =~ i ]]; then # Only define when shell is interacitve
# ------------------
STYLE='rrt'

__inner() { 
		curl --silent "cheat.sh/:list" \
		| fzf-tmux \
			-p 70%,60% \
			--layout=reverse --multi \
			--preview \
			"curl --silent cheat.sh/{}\?style=$STYLE" \
			--bind "?:toggle-preview" \
			--preview-window hidden,60% \
}

__base() {
	curl --silent "cheat.sh/$(__inner)?style=$STYLE"
}

_fzf_cheat_sh() {
		__base | bat --style=plain
}

_fzf_cheat_sh_widget() {
	zle push-input;
    BUFFER="_fzf_cheat_sh";
    zle accept-line;
}

__fzf_cheat_init() {
  eval "zle -N _fzf_cheat_sh_widget"
  eval "bindkey '' _fzf_cheat_sh_widget"
}
__fzf_cheat_init
# --------------------
fi
