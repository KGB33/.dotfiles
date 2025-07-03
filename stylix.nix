{pkgs, ...}: {
  stylix = let
    everforestLight = {
      base00 = "#fffbef"; # bg0
      base01 = "#f8f5e4"; # bg1
      base02 = "#edeada"; # bg3
      base03 = "#a6b0a0"; # grey1
      base04 = "#939f91"; # grey2
      base05 = "#5c6A72"; # fg
      base06 = "#414b50"; # bg3
      base07 = "#272e33"; # bg0
      base08 = "#f85552"; # red
      base09 = "#f57d26"; # orange
      base0A = "#dfa000"; # yellow
      base0B = "#8da101"; # green
      base0C = "#35a77c"; # aqua
      base0D = "#3a94c5"; # blue
      base0E = "#df69ba"; # purple
      base0F = "#829181"; # gray 2
    };
  in {
    enable = true;
    autoEnable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    base16Scheme = everforestLight;
    fonts = {
      monospace = {
        package = pkgs.fira-code;
        name = "FiraCode Nerd Font";
      };
    };
    targets.firefox.profileNames = ["default"];
  };
}
