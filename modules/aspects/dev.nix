{ apps, ... }:
{
  den.aspects.dev = {
    includes = with apps; [
      tmux
      tv
    ];

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
