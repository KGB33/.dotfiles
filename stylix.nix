{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-light-hard.yaml";
    targets = {
      kde.enable = false;
    };
    fonts = {
      monospace = {
        package = pkgs.fira-code;
        name = "FiraCode Nerd Font";
      };
    };
  };
}
