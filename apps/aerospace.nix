{
  lib,
  pkgs,
  config,
  ...
}: {
  options.apps.aerospace.enable = lib.mkEnableOption "aerospace" // {default = pkgs.stdenv.isDarwin;};

  config = lib.mkIf config.apps.aerospace.enable {
    services.jankyborders = {
      enable = true;
      settings = {
        active_color = "#8da101";
        inactive_color = "#35a77c";
      };
    };

    programs.aerospace = {
      enable = true;
      launchd.enable = true;
      userSettings = {
        start-at-login = false;
        mode = {
          main.binding = let
            workspaces = [
              "0"
              "1"
              "2"
              "3"
              "4"
              "5"
              "6"
              "7"
              "8"
              "9"
              "a"
              "b"
              "c"
              "d"
              "e"
              "f"
              "g"
              "h"
              "i"
              "j"
              "k"
              "l"
              "m"
              "n"
              "o"
              "p"
              "q"
              "r"
              "s"
              "t"
              "u"
              "v"
              "w"
              "x"
              "y"
              "z"
            ];
            mappings = builtins.concatLists (map (c: [
                {
                  name = "alt-${c}";
                  value = "workspace ${c}";
                }
                {
                  name = "alt-shift-${c}";
                  value = "move-node-to-workspace ${c}";
                }
              ])
              workspaces);
          in
            builtins.listToAttrs mappings
            // {
              alt-tab = "workspace-back-and-forth";
              alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
              alt-shift-semicolon = "mode service";
            };
          service.binding = {
            r = ["flatten-workspace-tree" "mode main"];
            f = ["layout floating tiling" "mode main"];
            backspace = ["close-all-windows-but-current" "mode main"];
          };
        };
      };
    };
  };
}
