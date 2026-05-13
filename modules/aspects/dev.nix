{ apps, ... }:
{
  den.aspects.dev = {
    includes = with apps; [
      nvim
      vcs
      tmux
      tv
      nushell
      shell
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
