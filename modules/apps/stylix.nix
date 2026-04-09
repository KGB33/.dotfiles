{inputs, ...}: {
  flake-file.inputs.stylix.url = "github:danth/stylix";

  flake.modules.homeManager.stylix = {pkgs, ...}: {
    imports = [inputs.stylix.homeModules.stylix];

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
      fonts.monospace = {
        package = pkgs.fira-code;
        name = "FiraCode Nerd Font";
      };
      targets.firefox.profileNames = ["default"];
      targets.neovim.enable = false;
    };
  };
}
