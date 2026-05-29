{
  apps,
  den,
  inputs,
  ...
}:
{

  flake-file.inputs.emux = {
    url = "github:kgb33/emux";
    inputs.nixpkgs.follows = "nixpkgs";
  };

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
      voxtype
    ];

    homeManager =
      { pkgs, ... }:
      {
        den.unfree.predicates = [
          "obsidian"
          "claude-code"
        ];
        home.packages =
          with pkgs;
          [
            bat
            obsidian
            claude-code
            ripgrep
            fd
            doggo
          ]
          ++ [
            inputs.emux.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
      };
  };
}
