{
  den.aspects.geppetto = {
    # geppetto host provides some home-manager defaults to its users.
    homeManager.programs.direnv.enable = true;

    # NixOS configuration for geppetto.
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.hello];
    };

    # <host>.provides.<user>, via den.provides.mutual-provider
    provides.kgb33 = {user, ...}: {
      homeManager.programs.tmux.enable = user.name == "kgb33";
    };
  };
}
