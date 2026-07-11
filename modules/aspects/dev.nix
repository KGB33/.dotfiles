{
  apps,
  den,
  inputs,
  ...
}:
{

  flake-file.inputs = {
    emux = {
      url = "github:kgb33/emux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      claude
      nushell
      shell
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
            bat
            obsidian
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
