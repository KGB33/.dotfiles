{ config, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    loginFile.source = ./login.nu;
    environmentVariables = builtins.mapAttrs
      (
        name: value: "\"${builtins.toString value}\""
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
  };
}
