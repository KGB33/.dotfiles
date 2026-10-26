{
  apps,
  den,
  ...
}:
{

  den.aspects.dev = {
    includes = with apps; [
      den.aspects.unfree
      microsandbox
      nushell
      nvim
      pi
      shell
      taskwarrior
      tmux
      tv
      vcs
      wezterm
    ];

    homeManager =
      { pkgs, ... }:
      {
        den.unfree.predicates = [
          "obsidian"
        ];
        home.packages =
          with pkgs;
          [
            awscli2
            bat
            doggo
            fd
            fnlfmt
            gh
            obsidian
            python3
            ripgrep
            tuicr
          ];
      };
  };
}
