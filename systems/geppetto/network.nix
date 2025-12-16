{...}: {
  imports = [../../components/wireguard.nix];
  networking = {
    hostName = "geppetto";
    firewall = {
      allowedTCPPorts = [];
    };
  };
}
