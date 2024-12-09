{
  pkgs,
  lib,
  mac-app-util,
  ...
}: {
  imports = [
    mac-app-util.homeManagerModules.default
    ../zsh/zsh.nix
  ];

  home.username = "keltonbassingthwaite";
  home.homeDirectory = "/Users/keltonbassingthwaite";

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "postman"
    ];

  home.packages = with pkgs; [
    (php82.buildEnv {
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
    postgresql
    postman
  ];

  programs.git.userEmail = "kelton@cdlpowersuite.com";
}
