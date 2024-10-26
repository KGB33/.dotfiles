{
  pkgs,
  nasty',
  ...
}: {
  imports = [
    ./windowManagers/sway/sway.nix
    ./windowManagers/river/river.nix
  ];

  home.username = "kgb33";
  home.homeDirectory = "/home/kgb33";

  home.packages = with pkgs;
    [
      freecad
      brightnessctl
      grim
      hyprlock
      prusa-slicer
      slurp
      wl-clipboard
      xdg-utils
    ]
    ++ [nasty'];

  home.file = {
    # TODO: Move these hypr* configs into their programs/services
    ".config/hypr/hypridle.conf".source = hypr/hypridle.conf;
    ".config/hypr/hyprlock.conf".source = hypr/hyprlock.conf;
    ".config/hypr/hyprpaper.conf".source = hypr/hyprpaper.conf;
  };

  xdg = {
    enable = true;
    portal = {
      config.common.default = "*"; # Just use the first one found.
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-wlr];
    };
  };

  programs.fuzzel = {
    enable = true;
  };

  programs.eww = {
    enable = true;
    configDir = ./eww;
  };

  programs.git.signing = {
    key = "B9192CEACB44520B";
    signByDefault = true;
  };

  services.ssh-agent.enable = true;

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
}
