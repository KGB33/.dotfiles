{
  den,
  apps,
  ...
}:
{
  den.aspects.kgb33 = {
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
        den.aspects.setHost
        apps.niri
        apps.hyprland
        apps.vicinae
        apps.nushell-login
        apps.steam
        apps.ffxiv

        den.aspects.dev
        den.aspects.stylix

        nh
        ssh-agent

        <den/primary-user>
      ];

    # User configures NixOS hosts it lives on.
    nixos =
      { pkgs, ... }:
      {
        users.users.kgb33.packages = [ pkgs.vim ];
        users.users.kgb33.extraGroups = [ "video" ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          btop
          firefox
        ];
      };

    # <user>.provides.<host>, via den.provides.mutual-provider
    provides.geppetto =
      { host, ... }:
      {
        nixos.programs.nh.enable = true;
      };
  };

  # This is a context-aware aspect, that emits configurations
  # **anytime** at least the `user` data is in context.
  # read more at https://vic.github.io/den/context-aware.html
  den.aspects.setHost =
    { host, ... }:
    {
      networking.hostName = host.hostName;
    };
}
