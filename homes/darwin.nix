{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.mac-app-util.homeManagerModules.default
  ];

  options = {
    darwinHome.enable = lib.mkOption {
      default = pkgs.stdenv.isDarwin;
      description = "Enables Default Darwin Home Module";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.darwinHome.enable {
    home.username = "keltonbassingthwaite";
    home.homeDirectory = "/Users/keltonbassingthwaite";

    apps.zsh.enable = true;
    apps.vicinae.enable = false;

    home.packages = with pkgs; [
      (php82.buildEnv {
        extraConfig = ''
          memory_limit = 2G
        '';
        extensions = {
          enabled,
          all,
        }:
          enabled
          ++ (with all; [
            # swoole
          ]);
      })
      _1password-cli
      colima
      nodejs_latest
      php82Packages.composer
      postgresql
      wireguard-tools
      zed-editor
    ];

    programs.git = {
      settings.user.email = "kelton@cdlpowersuite.com";
      settings.gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
    };
    home.file.".config/git/allowed_signers".text = ''      keltonbassingthwaite@gmail.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXEwMKmnpJVai5TxjTmDRnju98Dp9RgPmMXqahwuh8m kelton_bassingthwaite@cdlpowersuite.com
    '';
  };
}
