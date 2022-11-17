# Inspired by https://www.youtube.com/watch?v=hJzqEAf2U4I

if [[ $- =~ i ]]; then # Only define when shell is interacitve
# ------------------
STYLE='rrt'

__fzf_cheat_selector() { 
		curl --silent "cheat.sh/:list" \
		| fzf-tmux \
			-p 70%,60% \
			--layout=reverse --multi \
			--preview \
			"curl --silent cheat.sh/{}\?style=$STYLE" \
			--bind "?:toggle-preview" \
			--preview-window hidden,60% \
}

fzf_cheat_sh() {
	curl --silent "cheat.sh/${1:=$(__fzf_cheat_selector)}?style=$STYLE" | bat --style=plain
}

_fzf_cheat_sh_widget() {
	zle push-input;
	BUFFER="fzf_cheat_sh $(__fzf_cheat_selector)";
    zle accept-line;
}

__fzf_cheat_init() {
  eval "zle -N _fzf_cheat_sh_widget"
  eval "bindkey '' _fzf_cheat_sh_widget"
}
__fzf_cheat_init
# --------------------
fi
