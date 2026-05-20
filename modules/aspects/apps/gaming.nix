{ den, ... }:
{

  apps.steam.nixos =
    { ... }:
    {
      den.unfree.predicates = [
        "steam"
        "steam-unwrapped"
      ];
      programs.steam = {
        enable = true;
      };
      programs.gamemode.enable = true;
    };

  apps.ffxiv.homeManager =
    { pkgs, ... }:
    {
      den.unfree.predicates = [
        "steam-unwrapped" # Via xivlauncher
        "fflogs"
      ];
      home.packages = with pkgs; [
        xivlauncher
        fflogs
        prismlauncher
      ];
    };

}
