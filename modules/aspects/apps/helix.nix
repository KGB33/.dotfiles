{ ... }:
{
  apps.helix.homeManager = { pkgs, ... }: {
    programs.helix = {
      package = pkgs.steelix;
      enable = true;
    };
    xdg.configFile = {
      "helix/helix.scm".source = ./helix/helix.scm;
      "helix/init.scm".source = ./helix/init.scm;
    };
  };
}
