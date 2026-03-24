{...}: {
  flake.modules.nixos.networking-base = {...}: {
    networking = {
      useDHCP = false; # Set per-interface
      useNetworkd = false; # Manually configure interfaces
      networkmanager.enable = false;
      nameservers = ["10.0.9.53" "1.1.1.1" "1.0.0.1"];
      hosts = {
        # TODO: Ensure Homelab DNS server is used locally.
        "10.0.9.104" = ["blog.kgb33.dev" "graf.kgb33.dev"];
      };
      firewall = {
        enable = true;
      };
    };

    systemd.network.enable = true;
  };

  flake.modules.nixos.networking-wireless = {...}: {
    networking.wireless.iwd.enable = true;
    systemd.network = {
      networks."10-wlan0" = {
        matchConfig.Name = "wlan0";
        networkConfig.DHCP = "yes";
      };
    };
  };
  flake.modules.nixos.networking-wired = {...}: {
  };
}
