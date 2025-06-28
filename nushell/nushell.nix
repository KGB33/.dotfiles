{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [carapace];
  programs.nushell = {
    enable = false;
    plugins = with pkgs.nushellPlugins; [
      gstat
      query
      net
      highlight
      formats
    ];
    configFile.source = ./config.nu;
    loginFile.source = ./login.nu;
    envFile.source = ./env.nu;
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
}
