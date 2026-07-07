{
  inputs,
  den,
  apps,
  ...
}:
{
  den.aspects.keltonbassingthwaite = {
    # For small, private one-shot aspects, use let-bindings like here.
    # for more complex or re-usable ones, define on their own modules,
    # as part of any aspect-subtree.
    includes =
      let
        # hack for nixf linter to keep findFile :/
        unused = den.lib.take.unused __findFile;
        __findFile = unused den.lib.__findFile;
        nh.homeManager =
          { ... }:
          {
            programs.nh.enable = true;
          };

        ssh-agent.homeManager =
          { ... }:
          {
            services.ssh-agent.enable = true;
          };

      in
      [
        den.aspects.dev
        den.aspects.stylix
        apps.aerospace
        apps.nushell-darwin

        nh
        ssh-agent

      ];

    homeManager =
      { pkgs, ... }:
      {
        programs.git.settings.user.email = "kelton@cdlpowersuite.com";
        programs.jujutsu.settings.user.email = "kelton@cdlpowersuite.com";
        den.unfree.predicates = [
          "graphite-cli"
          "graphite-cli-unwrapped"
        ];
        home.packages = with pkgs; [
          btop
          bun
          codex
          codex
          colima
          docker-client
          firefox
          inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.graphite-cli
          nodejs-slim_latest
          php82
          php82Packages.composer
          wireguard-tools
        ];
      };

  };
}
