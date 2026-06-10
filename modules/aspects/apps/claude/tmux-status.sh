set -euo pipefail

# Only track claude sessions running inside tmux.
[ -n "${TMUX_PANE:-}" ] || exit 0

input=$(cat)
event=$(jq -r '.hook_event_name' <<<"$input")
session_id=$(jq -r '.session_id' <<<"$input")

dir="${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/claude-tmux}"
dir="${dir:-/tmp/claude-tmux-$(id -u)}"
mkdir -p "$dir"
file="$dir/$session_id.json"

case "$event" in
SessionEnd)
	rm -f "$file"
	exit 0
	;;
SessionStart)
	state=waiting
	msg="session started"
	;;
UserPromptSubmit | PostToolUse)
	state=busy
	msg=""
	;;
Notification)
	state=waiting
	msg=$(jq -r '.message // ""' <<<"$input")
	;;
Stop)
	state=waiting
	msg="turn complete"
	;;
*)
	exit 0
	;;
esac

tmp=$(mktemp "$dir/.tmp.XXXXXX")
jq -n \
	--arg pane "$TMUX_PANE" \
	--arg cwd "$(jq -r '.cwd // ""' <<<"$input")" \
	--arg state "$state" \
	--arg msg "$msg" \
	--argjson ts "$(date +%s)" \
	'{pane: $pane, cwd: $cwd, state: $state, msg: $msg, ts: $ts}' >"$tmp"
mv "$tmp" "$file"
