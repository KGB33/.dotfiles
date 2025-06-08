{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-light-hard.yaml";
    targets = {
      neovim.enable = true;
      wezterm.enable = true;
      hyprland.enable = true;
      hyprpaper.enable = true;
      hyprlock.enable = true;
      bat.enable = true;
      bemenu.enable = true;
      btop.enable = true;
      nixcord.enable = true;
      fuzzel. enable = true;
      k9s.enable = true;
      lazygit.enable = true;
      nushell.enable = true;
      qt.enable = true;
      starship.enable = true;
      tmux.enable = true;
      waybar.enable = true;
      yazi.enable = true;
    };
    fonts = {
      monospace = {
        package = pkgs.fira-code;
        name = "FiraCode Nerd Font";
      };
    };
    targets.firefox.profileNames = ["default"];
  };
}
