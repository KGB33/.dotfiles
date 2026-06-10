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
    llm-agents.url = "github:numtide/llm-agents.nix";
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
            ripgrep
            fd
            doggo
          ]
          ++ [
            inputs.emux.packages.${pkgs.stdenv.hostPlatform.system}.default
          ]
          ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
            claude-code
          ]);
      };
  };
}
