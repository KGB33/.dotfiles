{...}: {
  flake.modules.nixos.user-kgb33 = {pkgs, ...}: {
    programs.fish.enable = true;
    users.users.kgb33 = {
      isNormalUser = true;
      extraGroups = ["wheel" "docker" "podman" "video" "audio"];
      shell = pkgs.fish;
      openssh = {
        authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsItKA/n+4hj/qTtEURIGm3zpoelVwqyUOG88DqPGpB"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwbBIHzrrJhfKv9vB/+M70HNMd9Kr1B2FqnzYGh/Dfg"
        ];
      };
    };
  };
}
