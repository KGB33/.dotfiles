{self, ...}: {
  flake.modules.homeManager.kelton-mbp = {pkgs, ...}: {
    imports = with self.modules.homeManager; [base home-dev];

    home = {
      username = "keltonbassingthwaite";
      homeDirectory = "/Users/keltonbassingthwaite";
      stateVersion = "24.11";
      packages = with pkgs; [
        (php82.buildEnv {
          extraConfig = ''
            memory_limit = 2G
          '';
          extensions = {
            enabled,
            all,
            ...
          }:
            enabled;
        })
        _1password-cli
        colima
        php82Packages.composer
        postgresql
        wireguard-tools
        zed-editor
      ];
      file.".config/git/allowed_signers".text = ''
        keltonbassingthwaite@gmail.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXEwMKmnpJVai5TxjTmDRnju98Dp9RgPmMXqahwuh8m kelton_bassingthwaite@cdlpowersuite.com
      '';
    };

    programs.git = {
      settings.user.email = "kelton@cdlpowersuite.com";
      settings.gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
    };

    apps.zsh.enable = true;
  };
}
