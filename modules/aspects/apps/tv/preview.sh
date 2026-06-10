session="${1:?usage: tss-preview <session>}"

dir="${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/claude-tmux}"
dir="${dir:-/tmp/claude-tmux-$(id -u)}"

bold=$'\e[1m'
dim=$'\e[2m'
green=$'\e[32m'
yellow=$'\e[33m'
reset=$'\e[0m'

now=$(date +%s)
found=0

echo "${bold}Claude Code${reset}"
if [ -d "$dir" ]; then
	for f in "$dir"/*.json; do
		[ -e "$f" ] || continue
		pane=$(jq -r '.pane' "$f")
		# Resolve the pane to its current session; drop state files for dead panes.
		if ! pane_session=$(tmux display-message -pt "$pane" '#S' 2>/dev/null); then
			rm -f "$f"
			continue
		fi
		[ "$pane_session" = "$session" ] || continue
		found=1

		state=$(jq -r '.state' "$f")
		msg=$(jq -r '.msg' "$f")
		cwd=$(jq -r '.cwd' "$f")
		ts=$(jq -r '.ts' "$f")
		loc=$(tmux display-message -pt "$pane" '#I.#P')

		age=$((now - ts))
		if [ "$age" -ge 3600 ]; then
			age_s="$((age / 3600))h"
		elif [ "$age" -ge 60 ]; then
			age_s="$((age / 60))m"
		else
			age_s="${age}s"
		fi

		if [ "$state" = waiting ]; then
			badge="${yellow}⏳ WAITING${reset}"
		else
			badge="${green}● busy${reset}   "
		fi
		printf '%s  %s:%s  %s%s%s ago%s\n' \
			"$badge" "$(basename "$cwd")" "$loc" \
			"$dim" "${msg:+$msg — }" "$age_s" "$reset"
	done
fi
[ "$found" = 1 ] || echo "${dim}no agents${reset}"

echo
echo "${bold}Windows${reset}"
tmux list-windows -t "$session" -F '#{?window_active,*, } #I: #W (#{window_panes} panes)'
