{ inputs, ... }:
{
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.stylix = {
    nixos =
      { ... }:
      {
        programs.dconf.enable = true;
      };
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.stylix.homeModules.stylix ];

        fonts.fontconfig.enable = true;
        home.packages = with pkgs.nerd-fonts; [
          fira-code
        ];

        stylix = {
          enable = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.fira-code;
              name = "FiraCode Nerd Font";
            };
          };
        };

      };
  };
}
