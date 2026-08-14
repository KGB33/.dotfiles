def main [direction: string] {
  if ($env.HYPRLAND_INSTANCE_SIGNATURE? == null) {
    exit 0
  }

  let active = (hyprctl -j activeworkspace | from json | get id)
  let ids = (
    hyprctl -j workspaces
      | from json
      | where id > 0
      | sort-by id
      | get id
  )

  if (($ids | length) == 0) {
    exit 0
  }

  let current_idx = ($ids | enumerate | where item == $active | get index.0?)
  let current_idx = if $current_idx == null { 0 } else { $current_idx }
  let last_idx = (($ids | length) - 1)

  let target_idx = if $direction == "up" {
    if $current_idx >= $last_idx { 0 } else { $current_idx + 1 }
  } else if $direction == "down" {
    if $current_idx <= 0 { $last_idx } else { $current_idx - 1 }
  } else {
    exit 0
  }

  let target = ($ids | get $target_idx)
  let command = ([
    "hl.dispatch(hl.dsp.focus({workspace = "
    ($target | into string)
    "}))"
  ] | str join "")

  hyprctl eval $command | ignore
}
