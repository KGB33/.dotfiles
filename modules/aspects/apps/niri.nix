{ inputs, ... }:
{
  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  apps.niri = {
    includes =
      let
        # TODO, refactor into its own module
        wezterm.homeManager =
          { ... }:
          {
            programs.wezterm.enable = true;
          };
      in
      [ wezterm ];

    homeManager =
      { lib, ... }:
      {
        imports = [ inputs.niri.homeModules.niri ];

        programs.niri = {
          enable = true;
          settings = {
            binds =
              let
                binds =
                  {
                    suffixes,
                    prefixes,
                    substitutions ? { },
                  }:
                  let
                    replacer = lib.replaceStrings (lib.attrNames substitutions) (lib.attrValues substitutions);
                    format =
                      prefix: suffix:
                      let
                        actual-suffix =
                          if lib.isList suffix.action then
                            {
                              action = lib.head suffix.action;
                              args = lib.tail suffix.action;
                            }
                          else
                            {
                              inherit (suffix) action;
                              args = [ ];
                            };

                        action = replacer "${prefix.action}-${actual-suffix.action}";
                      in
                      {
                        name = "${prefix.key}+${suffix.key}";
                        value.action.${action} = actual-suffix.args;
                      };
                    pairs =
                      attrs: fn:
                      lib.concatMap (
                        key:
                        fn {
                          inherit key;
                          action = attrs.${key};
                        }
                      ) (lib.attrNames attrs);
                  in
                  lib.listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [ (format prefix suffix) ])));
              in
              lib.attrsets.mergeAttrsList [
                {
                  "Mod+G".action.spawn = "wezterm";
                  "Mod+B".action.spawn = "firefox";

                  "XF86AudioRaiseVolume".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
                  "XF86AudioLowerVolume".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
                  "XF86AudioMute".action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

                  "XF86MonBrightnessUp".action.spawn-sh = "brightnessctl set 10%+";
                  "XF86MonBrightnessDown".action.spawn-sh = "brightnessctl set 10%-";

                  "Mod+Q".action.close-window = [ ];

                  "Mod+Space".action.toggle-column-tabbed-display = [ ];

                  "XF86AudioNext".action.focus-column-right = [ ];
                  "XF86AudioPrev".action.focus-column-left = [ ];

                  "Mod+Tab".action.focus-window-down-or-column-right = [ ];
                  "Mod+Shift+Tab".action.focus-window-up-or-column-left = [ ];
                }
                (binds {
                  suffixes."U" = "workspace-down";
                  suffixes."I" = "workspace-up";
                  prefixes."Mod" = "focus";
                  prefixes."Mod+Ctrl" = "move-window-to";
                  prefixes."Mod+Shift" = "move";
                })
                {
                  "Mod+Comma".action.consume-window-into-column = [ ];
                  "Mod+Period".action.expel-window-from-column = [ ];

                  "Mod+R".action.switch-preset-column-width = [ ];
                  "Mod+F".action.maximize-column = [ ];
                  "Mod+Shift+F".action.fullscreen-window = [ ];
                  "Mod+C".action.center-column = [ ];

                  "Mod+Minus".action.set-column-width = "-10%";
                  "Mod+Plus".action.set-column-width = "+10%";
                  "Mod+Shift+Minus".action.set-window-height = "-10%";
                  "Mod+Shift+Plus".action.set-window-height = "+10%";

                  "Mod+Shift+Escape".action.toggle-keyboard-shortcuts-inhibit = [ ];
                  "Mod+Shift+E".action.quit = [ ];
                  "Mod+Shift+P".action.power-off-monitors = [ ];

                  "Mod+Shift+Ctrl+T".action.toggle-debug-tint = [ ];
                }
                (binds {
                  suffixes."h" = "column-left";
                  suffixes."j" = "window-down";
                  suffixes."k" = "window-up";
                  suffixes."l" = "column-right";
                  prefixes."Mod" = "focus";
                  prefixes."Mod+Ctrl" = "move";
                  prefixes."Mod+Shift" = "focus-monitor";
                  prefixes."Mod+Shift+Ctrl" = "move-window-to-monitor";
                  substitutions."monitor-column" = "monitor";
                  substitutions."monitor-window" = "monitor";
                })
              ];
          };
        };
      };
  };
}
