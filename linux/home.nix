{
  pkgs,
  lib,
  nasty',
  ...
}: {
  imports = [
    ./windowManagers/sway.nix
    ./windowManagers/river.nix
    ./windowManagers/hypr.nix
    ./windowManagers/niri.nix
    ./windowManagers/waybar.nix
    ../nixcord.nix
  ];

  home.username = "kgb33";
  home.homeDirectory = "/home/kgb33";

  home.packages = with pkgs;
    [
      brightnessctl
      freecad
      grim
      hyprlock
      netscanner
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
    enable = false;
    configDir = ./eww;
  };

  programs.git = {
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    extraConfig.gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
  };
  home.file.".config/git/allowed_signers".text = ''keltonbassingthwaite@gmail.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsItKA/n+4hj/qTtEURIGm3zpoelVwqyUOG88DqPGpB keltonbassingthwaite@gmail.com'';

  services.ssh-agent.enable = true;

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry-tty;
  };

  services.clipse = {
    package = pkgs.clipse;
    systemdTarget = "hyprland-session.target";
    enable = true;
  };
}
