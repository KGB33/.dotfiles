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
      claude
      microsandbox
      nushell
      nvim
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
            bat
            doggo
            fd
            obsidian
            ripgrep
            tuicr
          ]
          ++ [
            inputs.emux.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
      };
  };
}
