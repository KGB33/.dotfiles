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
    php82Packages.composer
    slack
    colima
    postgresql
    zed-editor
    _1password-cli
    _1password-gui
  ];

  programs.git.userEmail = "kelton@cdlpowersuite.com";
}
