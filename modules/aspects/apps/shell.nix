{ ... }:
{
  apps.shell.homeManager = {
    programs.starship = {
      enable = true;
      presets = [
        "nerd-font-symbols"
        "pure-preset"
      ];

    };

  };
}
