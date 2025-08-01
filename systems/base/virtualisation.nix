{pkgs, ...}: {
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    docker = {
      enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    podman-tui
  ];
}
