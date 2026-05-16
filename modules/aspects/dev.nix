{ apps, den, ... }:
{
  den.aspects.dev = {
    includes = with apps; [
      den.aspects.unfree
      wezterm
      nvim
      vcs
      tmux
      tv
      nushell
      shell
    ];

    homeManager =
      { pkgs, lib, ... }:
      {
        den.unfree.predicates = [ "obsidian" ];
        home.packages = with pkgs; [
          obsidian
          ripgrep
          fd
        ];
      };
  };
}
