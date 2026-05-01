{ apps, ... }:
{
  den.aspects.dev = {
    includes = [ apps.tmux ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          ripgrep
          fd
        ];
      };
  };
}
