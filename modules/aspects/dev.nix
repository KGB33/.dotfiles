{ apps, den, ... }:
{
  den.aspects.dev = {
    includes = with apps; [
      den.aspects.unfree
      wezterm
      nvim
      vcs
      taskwarrior
      tmux
      tv
      nushell
      shell
    ];

    homeManager =
      { pkgs, ... }:
      {
        den.unfree.predicates = [
          "obsidian"
          "claude-code"
        ];
        home.packages = with pkgs; [
          obsidian
          claude-code
          ripgrep
          fd
          doggo
        ];
      };
  };
}
