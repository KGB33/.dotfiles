{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    ../linux/windowManagers/sway.nix
    ../linux/windowManagers/river.nix
    ../linux/windowManagers/hypr.nix
    ../linux/windowManagers/niri.nix
    ../linux/windowManagers/waybar.nix
    ../nixcord.nix
  ];

  options = {
    linuxHome.enable = lib.mkOption {
      default = pkgs.stdenv.isLinux;
      description = "Enables Default Linux Home Module";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.linuxHome.enable {
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
        xivlauncher
      ]
      ++ [inputs.nasty];

    home.file = {
      # TODO: Move these hypr* configs into their programs/services
      ".config/hypr/hypridle.conf".source = ../linux/hypr/hypridle.conf;
      ".config/hypr/hyprlock.conf".source = ../linux/hypr/hyprlock.conf;
      ".config/hypr/hyprpaper.conf".source = ../linux/hypr/hyprpaper.conf;
    };

    xdg = {
      enable = true;
      portal = {
        config.common.default = "*"; # Just use the first one found.
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-wlr];
      };
    };
    systemd.user.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";

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
  };
}
