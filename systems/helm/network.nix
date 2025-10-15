{...}: {
  networking = {
    hostName = "helm";
    firewall = {
      allowedTCPPorts = [];
    };
  };
}
