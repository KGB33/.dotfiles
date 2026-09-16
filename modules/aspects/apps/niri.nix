{ apps, ... }:
{
  apps.niri = {
    includes = [ apps.wezterm ];

    nixos =
      { pkgs, ... }:
      {
        services.udev.packages = [ pkgs.brightnessctl ];

        services.displayManager.sessionPackages = [
          (pkgs.runCommand "niri-session-desktop" { passthru.providedSessions = [ "niri" ]; } ''
            mkdir -p $out/share/wayland-sessions
            cat > $out/share/wayland-sessions/niri.desktop <<EOF
            [Desktop Entry]
            Name=Niri
            Exec=${pkgs.niri}/bin/niri-session
            Type=Application
            EOF
          '')
        ];
      };

    homeManager =
      { lib, pkgs, ... }:
      let
        termfilechooser = pkgs.xdg-desktop-portal-termfilechooser;
        xwaylandSatellite = pkgs.xwayland-satellite;
      in
      {
        home.packages = [
          pkgs.brightnessctl
          pkgs.yazi
          xwaylandSatellite
        ];

        xdg = {
          portal = {
            extraPortals = [ termfilechooser ];
            config.niri = {
              default = [
                "gnome"
                "gtk"
              ];
              "org.freedesktop.impl.portal.Access" = "gtk";
              "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
              "org.freedesktop.impl.portal.Notification" = "gtk";
              "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
            };
          };

          configFile."xdg-desktop-portal-termfilechooser/niri".text = ''
            [filechooser]
            cmd=${termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
            default_dir=$HOME
            env=TERMCMD=${lib.getExe pkgs.wezterm} start --always-new-process --class termfilechooser
            open_mode=suggested
            save_mode=suggested
          '';
        };

        wayland.windowManager.niri = {
          enable = true;
          package = pkgs.niri;
          xwaylandSatellitePackage = null;
          settings = {
            _children = [
              {
                spawn-at-startup = [
                  (lib.getExe xwaylandSatellite)
                  ":0"
                ];
              }
            ];
            environment.DISPLAY = ":0";

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
                        value.${action} = if actual-suffix.args == [ ] then { } else actual-suffix.args;
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
                  "Mod+G".spawn = [ "wezterm" ];
                  "Mod+B".spawn = [ "firefox" ];

                  "XF86AudioRaiseVolume".spawn-sh = [ "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+" ];
                  "XF86AudioLowerVolume".spawn-sh = [ "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-" ];
                  "XF86AudioMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];

                  "XF86MonBrightnessUp".spawn-sh = [ "brightnessctl set 10%+" ];
                  "XF86MonBrightnessDown".spawn-sh = [ "brightnessctl set 10%-" ];

                  "Mod+Q".close-window = { };

                  "Mod+Space".toggle-column-tabbed-display = { };

                  "XF86AudioNext".focus-column-right = { };
                  "XF86AudioPrev".focus-column-left = { };

                  "Mod+Tab".focus-window-down-or-column-right = { };
                  "Mod+Shift+Tab".focus-window-up-or-column-left = { };
                }
                (binds {
                  suffixes."U" = "workspace-down";
                  suffixes."I" = "workspace-up";
                  prefixes."Mod" = "focus";
                  prefixes."Mod+Ctrl" = "move-window-to";
                  prefixes."Mod+Shift" = "move";
                })
                {
                  "Mod+Comma".consume-window-into-column = { };
                  "Mod+Period".expel-window-from-column = { };

                  "Mod+R".switch-preset-column-width = { };
                  "Mod+F".maximize-column = { };
                  "Mod+Shift+F".fullscreen-window = { };
                  "Mod+C".center-column = { };

                  "Mod+Minus".set-column-width = [ "-10%" ];
                  "Mod+Plus".set-column-width = [ "+10%" ];
                  "Mod+Shift+Minus".set-window-height = [ "-10%" ];
                  "Mod+Shift+Plus".set-window-height = [ "+10%" ];

                  "Mod+Shift+Escape".toggle-keyboard-shortcuts-inhibit = { };
                  "Mod+Shift+E".quit = { };
                  "Mod+Shift+P".power-off-monitors = { };

                  "Mod+Shift+Ctrl+T".toggle-debug-tint = { };
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
