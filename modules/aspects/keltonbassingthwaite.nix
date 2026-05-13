{
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

        nh
        ssh-agent

      ];

    homeManager =
      { pkgs, ... }:
      {
        programs.git.settings.user.email = "kelton@cdlpowersuite.com";
        programs.jujutsu.settings.user.email = "kelton@cdlpowersuite.com";
        home.packages = with pkgs; [
          colima
          bun
          nodejs-slim_latest
          codex
          php82
          php82Packages.composer
          docker-client
          btop
          firefox
        ];
      };

  };
}
