{
  pkgs,
  mac-app-util,
  ...
}: {
  imports = [
    mac-app-util.homeManagerModules.default
    ../zsh/zsh.nix
  ];

  home.username = "keltonbassingthwaite";
  home.homeDirectory = "/Users/keltonbassingthwaite";

  home.packages = with pkgs; [
    (php82.buildEnv {
      extraConfig = ''
        memory_limit = 2G
      '';
      extensions = {
        enabled,
        all,
      }:
        enabled
        ++ (with all; [
          # swoole
        ]);
    })
    _1password-cli
    colima
    nodejs_latest
    php82Packages.composer
    postgresql
    wireguard-tools
    zed-editor
  ];

  programs.git.userEmail = "kelton@cdlpowersuite.com";

  programs.aerospace = {
    enable = true;
    userSettings = {
      start-at-login = true;
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
}
