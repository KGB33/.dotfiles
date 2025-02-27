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
    claude-code
    colima
    nodejs_latest
    php82Packages.composer
    postgresql
    slack
    zed-editor
  ];

  programs.git.userEmail = "kelton@cdlpowersuite.com";
}
