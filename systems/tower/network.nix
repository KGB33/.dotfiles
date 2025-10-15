{...}: {
  networking = {
    hostName = "tower";
    firewall = {
      allowedTCPPorts = [];
    };
  };
}
