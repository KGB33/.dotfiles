{ lib, ... }:
{
  apps.shell.homeManager = {

    programs.atuin = {
      enable = true;
      daemon.enable = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.starship = {
      enable = true;
      presets = [
        "nerd-font-symbols"
        "pure-preset"
      ];

    };

    programs.carapace = {
      enable = true;
    };

  };
}
