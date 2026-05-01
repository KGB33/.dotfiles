{
  den.aspects.geppetto = {
    # geppetto host provides some home-manager defaults to its users.
    homeManager.programs.direnv.enable = true;

    # NixOS configuration for geppetto.
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.hello ];
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
        };

        boot.loader.systemd-boot = {
          enable = true;
          configurationLimit = 16;
        };
      };

    # <host>.provides.<user>, via den.provides.mutual-provider
    provides.kgb33 =
      { user, ... }:
      {
        homeManager.programs.tmux.enable = user.name == "kgb33";
      };
  };
}
