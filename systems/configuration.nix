{
  config,
  pkgs,
  ...
}: {
  imports = [];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };

  services.fwupd.enable = true;

  networking = {
    wireless.iwd.enable = true;
    useDHCP = false; # Set per-interface
    useNetworkd = false; # Manually configure interfaces
    networkmanager.enable = false;
    nameservers = ["10.0.8.53" "1.1.1.1" "1.0.0.1"];
    hosts = {
      # "174.31.116.214" = [ "traefik.k8s.kgb33.dev" ];
      "10.0.9.104" = ["blog.kgb33.dev" "graf.kgb33.dev"];
    };
    firewall = {
      enable = true;
    };
  };

  systemd.network = {
    enable = true;
    # Wifi
    networks."10-wlan0" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
    };
  };

  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;
  };
  services.blueman.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.pam.services = {
    hyprlock = {};
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Shells
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
