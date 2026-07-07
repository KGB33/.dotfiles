{ ... }:
{
  apps.helix.homeManager = { pkgs, config, ... }: {
    programs.helix = {
      package = pkgs.steelix;
      enable = true;
      extraPackages = with pkgs; [ steel-language-server ];
    };
    xdg.configFile = {
      "helix/helix.scm".source = ./helix/helix.scm;
      "helix/init.scm".source = ./helix/init.scm;
    };

    home.sessionVariables."STEEL_LSP_HOME" = "${config.xdg.configHome}/steel_lsp/";
  };
}
