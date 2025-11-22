{...}: {
  networking = {
    hostName = "helm";
    firewall = {
      allowedTCPPorts = [];
    };
  };

  systemd.network = {
    networks."05-eth0" = {
      matchConfig.Name = "enp74s0";
      networkConfig.DHCP = "yes";
    };
  };
}
