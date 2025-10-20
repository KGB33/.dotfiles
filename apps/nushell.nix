{
  config,
  lib,
  pkgs,
  ...
}: {
  options.apps.nushell.enable = lib.mkEnableOption "nushell" // {default = true;};

  config = lib.mkIf config.apps.nushell.enable {
    home.packages = with pkgs; [carapace];
    programs.nushell = {
      enable = true;
      plugins = with pkgs.nushellPlugins; [
        gstat
        query
        # net
        # highlight
        formats
      ];
      configFile.source = ./nushell/config.nu;
      loginFile.source = ./nushell/login.nu;
      envFile.source = ./nushell/env.nu;
      environmentVariables =
        builtins.mapAttrs
        (
          name: value: "${builtins.toString value}"
        )
        config.home.sessionVariables;
    };

    # Enable nushell integrations
    services = {
      gpg-agent.enableNushellIntegration = true;
    };
    programs = {
      atuin.enableNushellIntegration = true;
      broot.enableNushellIntegration = true;
      direnv.enableNushellIntegration = true;
      eza.enableNushellIntegration = false; # No table output
      starship.enableNushellIntegration = true;
      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
  };
}
