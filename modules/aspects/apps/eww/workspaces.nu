def workspaces [] {
  niri msg --json workspaces
    | from json
    | sort-by idx
    | each {|ws|
      {
        id: $ws.idx
        onclick: $"niri msg action focus-workspace ($ws.idx)"
        class: ([
          (if $ws.is_urgent { "ws-urgent" })
          (if $ws.is_active { "ws-active" })
          (if $ws.is_focused { "ws-focused" })
        ] | compact | str join " ")
      }
    }
    | to json --raw
}

if ($env.NIRI_SOCKET? == null) {
  loop { sleep 1hr }
}

print (workspaces)

niri msg --json event-stream
  | lines
  | each {|event| if ($event | str contains "Workspace") { print (workspaces) } }
  | ignore
