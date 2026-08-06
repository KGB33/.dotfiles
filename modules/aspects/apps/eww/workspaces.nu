def workspaces [] {
  niri msg --json workspaces
    | from json
    | sort-by idx
    | each {|ws|
      {
        id: $ws.idx
        class: ([
          (if $ws.is_urgent { "ws-urgent" })
          (if $ws.is_active { "ws-active" })
          (if $ws.is_focused { "ws-focused" })
        ] | compact | str join " ")
      }
    }
    | to json --raw
}

niri msg --json event-stream
  | lines
  | each {|event| if ($event | str contains "Workspace") { print (workspaces) } }
  | ignore
