{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ carapace ];
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    loginFile.source = ./login.nu;
    envFile.source = ./env.nu;
    extraConfig =
      let
        path = ./cmp;
        cmpDir = builtins.readDir path;
        readCmpFiles = fileName: builtins.readFile "${path}/${fileName}";
      in
      builtins.concatStringsSep "\n" (map readCmpFiles (builtins.attrNames cmpDir));
    environmentVariables = builtins.mapAttrs
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
  };
}
