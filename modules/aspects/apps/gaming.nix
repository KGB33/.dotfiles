{ den, ... }:
{

  apps.steam.nixos =
    { pkgs, ... }:
    {
      den.unfree.predicates = [
        "steam"
        "steam-unwrapped"
      ];
      programs.steam = {
        enable = true;
        extest.enable = true;
        extraPackages = [pkgs.hidapi];
      };
      programs.gamemode.enable = true;
    };

  apps.ffxiv.homeManager =
    { pkgs, ... }:
    {
      den.unfree.predicates = [
        "steam-unwrapped" # Via xivlauncher
        "fflogs"
        "discord"
        "spotify"
      ];
      home.packages = with pkgs; [
        discord
        spotify
        xivlauncher
        fflogs
        prismlauncher
      ];
    };

}
