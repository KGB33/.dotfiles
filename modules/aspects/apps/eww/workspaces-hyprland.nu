def workspaces [] {
  let active = (hyprctl -j activeworkspace | from json)
  let active_ids = (
    hyprctl -j monitors
      | from json
      | each {|monitor| $monitor.activeWorkspace.id }
  )

  hyprctl -j workspaces
    | from json
    | where id > 0
    | sort-by id
    | each {|ws|
      {
        id: $ws.id
        onclick: ([
          "hyprctl eval 'hl.dispatch(hl.dsp.focus({workspace = "
          ($ws.id | into string)
          "}))'"
        ] | str join "")
        class: ([
          (if ($ws.id in $active_ids) { "ws-active" })
          (if $ws.id == $active.id { "ws-focused" })
        ] | compact | str join " ")
      }
    }
    | to json --raw
}

if ($env.HYPRLAND_INSTANCE_SIGNATURE? == null) {
  loop { sleep 1hr }
}

let socket = $"($env.XDG_RUNTIME_DIR)/hypr/($env.HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock"

print (workspaces)

^@socat@ -U - UNIX-CONNECT:($socket)
  | lines
  | each {|event|
    if (
      ($event | str contains "workspace") or
      ($event | str contains "focusedmon") or
      ($event | str contains "urgent") or
      ($event | str contains "openwindow") or
      ($event | str contains "closewindow") or
      ($event | str contains "movewindow")
    ) {
      print (workspaces)
    }
  }
  | ignore
